-- Local AI models, per machine. Everything runs through Ollama; nothing leaves the machine.
--
-- Two roles, each with its own model:
--   complete  inline completion while typing (minuet-ai). Must be FIM-capable and fast.
--   chat      chat and inline edits (CodeCompanion). Can be bigger and slower.
--
-- The choice lives in ~/.config/ai/config.json, the same per-machine file as the `ai` command
-- (never committed), under "nvim": { "complete": "...", "chat": "..." }. On a machine with more
-- VRAM, change it there or with :AIModel; the defaults below are what fits an 8 GB GPU.
-- "chat_ctx" (tokens of context for the chat) is optional; keep it equal to the chat model's num_ctx.
-- OLLAMA_HOST is honoured, as in `ai`.
local M = {}

-- Measured on an RTX 5060 (8 GB), Ollama:
--   complete  qwen2.5-coder:1.5b-base   ~300 ms per suggestion, always loaded next to the chat model
--   chat      qwen3.6-128k              qwen3.6:35b-a3b-coding (MoE, 3B active) with a 128k context
--                                       (config/ollama/): ~43 tok/s, 91% on the GPU, and the agent
--                                       that won the benchmark (10/10 tasks, no broken tool calls).
--                                       Shared with opencode: one loaded copy for both.
--             qwen3-coder:30b           ~38 tok/s, but its tool calls broke in 2 of 5 runs, and it
--                                       evicted the completion model (4-11 s reloads).
M.defaults = {
  complete = "qwen2.5-coder:1.5b-base",
  chat = "qwen3.6-128k",
}

-- Must match qwen3.6-128k's num_ctx: a different value makes Ollama load a second copy.
M.default_chat_ctx = 131072

M.roles = { "complete", "chat" }
M.path = vim.fn.expand("~/.config/ai/config.json")

function M.host()
  local host = vim.env.OLLAMA_HOST
  if not host or host == "" then
    host = "http://localhost:11434"
  end
  if not host:match("^https?://") then
    host = "http://" .. host
  end
  return (host:gsub("/+$", ""))
end

--- The whole config file. nil + error message if it exists but is not valid JSON.
local function read()
  local f = io.open(M.path, "r")
  if not f then
    return {}
  end
  local text = f:read("*a")
  f:close()
  if vim.trim(text) == "" then
    return {}
  end
  local ok, cfg = pcall(vim.json.decode, text)
  if not ok or type(cfg) ~= "table" then
    return nil, ("%s is not valid JSON: fix or delete it"):format(M.path)
  end
  return cfg
end

local function setting(key)
  local nv = (read() or {}).nvim
  return type(nv) == "table" and nv[key] or nil
end

---@param role "complete"|"chat"
function M.model(role)
  local m = setting(role)
  return type(m) == "string" and m ~= "" and m or M.defaults[role]
end

function M.chat_ctx()
  local n = tonumber(setting("chat_ctx"))
  return n and n > 0 and math.floor(n) or M.default_chat_ctx
end

--- Saves the model for a role, keeping every other key in the file (the `ai` command's too).
--- Refuses to touch a file it cannot parse, so nothing in it is lost.
function M.set(role, model)
  local cfg, err = read()
  if not cfg then
    vim.notify(err, vim.log.levels.ERROR, { title = "AI" })
    return false
  end
  cfg.nvim = type(cfg.nvim) == "table" and cfg.nvim or {}
  cfg.nvim[role] = model
  vim.fn.mkdir(vim.fs.dirname(M.path), "p")
  vim.fn.writefile(vim.split(vim.json.encode(cfg, { indent = "  " }), "\n"), M.path)
  for _, fn in ipairs(M.listeners[role] or {}) do
    fn(model)
  end
  return true
end

--- Plugins register here to pick up a model change without restarting.
M.listeners = { complete = {}, chat = {} }
function M.on_change(role, fn)
  table.insert(M.listeners[role], fn)
end

--- Models installed in Ollama.
function M.installed()
  local res = vim.system({ "curl", "-fsS", "--max-time", "3", M.host() .. "/api/tags" }, { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  local ok, data = pcall(vim.json.decode, res.stdout)
  if not ok then
    return nil
  end
  local names = vim.tbl_map(function(m)
    return m.name
  end, data.models or {})
  table.sort(names)
  return names
end

--- :AIModel [complete|chat] — pick a model for a role.
function M.pick(role)
  if not role or role == "" then
    return vim.ui.select(M.roles, {
      prompt = "AI model for",
      format_item = function(r)
        return ("%-9s %s"):format(r, M.model(r))
      end,
    }, function(r)
      if r then
        M.pick(r)
      end
    end)
  end
  if not M.defaults[role] then
    return vim.notify("Role must be one of: " .. table.concat(M.roles, ", "), vim.log.levels.ERROR)
  end
  local names = M.installed()
  if not names then
    return vim.notify("Ollama is not reachable at " .. M.host(), vim.log.levels.ERROR, { title = "AI" })
  end
  local current = M.model(role)
  vim.ui.select(names, {
    prompt = ("Model for %s (now: %s)"):format(role, current),
    format_item = function(n)
      return n == current and (n .. "  ●") or n
    end,
  }, function(name)
    if name and M.set(role, name) then
      vim.notify(("%s → %s"):format(role, name), vim.log.levels.INFO, { title = "AI" })
    end
  end)
end

vim.api.nvim_create_user_command("AIModel", function(args)
  M.pick(args.args)
end, {
  nargs = "?",
  complete = function()
    return M.roles
  end,
  desc = "Pick the local model for completion or chat",
})

return M
