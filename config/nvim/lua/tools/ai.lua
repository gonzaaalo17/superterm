-- Local AI models, per machine. Everything runs through Ollama; nothing leaves the machine.
--
-- Two roles, each with its own model:
--   complete  inline completion while typing (minuet-ai). Must be FIM-capable and fast.
--   chat      chat and inline edits (CodeCompanion). Can be bigger and slower.
--
-- The choice lives in ~/.config/ai/config.json, the same per-machine file as the `ai` command
-- (never committed), under "nvim": { "complete": "...", "chat": "..." }. On a machine with more
-- VRAM, change it there or with :AIModel; the defaults below are what fits an 8 GB GPU.
-- "chat_ctx" (tokens of context for the chat) is optional: raise it on a bigger GPU.
-- OLLAMA_HOST is honoured, as in `ai`.
local M = {}

-- Measured on an RTX 5060 (8 GB), Ollama, ~1.1k-token FIM prompt / 16k-token chat context:
--   complete  qwen2.5-coder:1.5b-base   ~300 ms per suggestion, 1.2 GB, always on the GPU
--             qwen2.5-coder:7b          ~940 ms
--   chat      qwen2.5-coder:14b         ~11 tok/s, 45% on CPU. It does not fit next to the
--                                       completion model, so switching between typing and chat
--                                       reloads one of them (~4-5 s the first time).
--             qwen2.5-coder:7b          ~74 tok/s, fits on the GPU next to the 1.5b: no reloads.
M.defaults = {
  complete = "qwen2.5-coder:1.5b-base",
  chat = "qwen2.5-coder:14b",
}

M.default_chat_ctx = 16384

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

local function read()
  local f = io.open(M.path, "r")
  if not f then
    return {}
  end
  local ok, cfg = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and type(cfg) == "table" and cfg or {}
end

---@param role "complete"|"chat"
function M.model(role)
  local nv = read().nvim
  return type(nv) == "table" and nv[role] or M.defaults[role]
end

function M.chat_ctx()
  local nv = read().nvim
  return type(nv) == "table" and tonumber(nv.chat_ctx) or M.default_chat_ctx
end

--- Saves the model for a role, keeping every other key in the file (the `ai` command's too).
function M.set(role, model)
  local cfg = read()
  cfg.nvim = type(cfg.nvim) == "table" and cfg.nvim or {}
  cfg.nvim[role] = model
  vim.fn.mkdir(vim.fs.dirname(M.path), "p")
  vim.fn.writefile(vim.split(vim.json.encode(cfg, { indent = "  " }), "\n"), M.path)
  for _, fn in ipairs(M.listeners[role] or {}) do
    fn(model)
  end
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
    if name then
      M.set(role, name)
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
