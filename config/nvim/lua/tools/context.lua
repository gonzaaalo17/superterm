-- What the user is looking at in this Neovim, as plain text for an agent in another tmux window.
-- bin/nvim-context finds the nvim of the current tmux session and calls get() through its
-- server socket:
--
--   nvim --server "$sock" --remote-expr 'luaeval("require(\"tools.context\").get()")'
--
-- Read-only: it never changes the editor's state.
local M = {}

local MAX_SELECTION_LINES = 200
local MAX_DIAGNOSTICS = 50

local function rel(path)
  if path == "" then
    return "[No Name]"
  end
  local cwd = vim.fn.getcwd()
  if vim.startswith(path, cwd .. "/") then
    return path:sub(#cwd + 2)
  end
  return vim.fn.fnamemodify(path, ":~")
end

-- The window the user was last in, skipping floats and special buffers (pickers, trees, chat).
local function main_window()
  local cur = vim.api.nvim_get_current_win()
  local function usable(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == ""
  end
  if usable(cur) then
    return cur
  end
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and usable(prev) then
    return prev
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if usable(win) then
      return win
    end
  end
  return cur
end

function M.get()
  local out = {}
  local function add(s)
    out[#out + 1] = s
  end

  local win = main_window()
  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local ft = vim.bo[buf].filetype

  add("Working directory: " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~"))
  add(
    ("Current file: %s%s (line %d, column %d of %d lines%s)"):format(
      rel(name),
      ft ~= "" and (" [" .. ft .. "]") or "",
      cursor[1],
      cursor[2] + 1,
      vim.api.nvim_buf_line_count(buf),
      vim.bo[buf].modified and ", UNSAVED CHANGES" or ""
    )
  )

  -- Last visual selection in that buffer (the marks stay after leaving visual mode).
  local s, e = vim.api.nvim_buf_get_mark(buf, "<"), vim.api.nvim_buf_get_mark(buf, ">")
  if s[1] > 0 and e[1] >= s[1] then
    local last = math.min(e[1], s[1] + MAX_SELECTION_LINES - 1)
    local lines = vim.api.nvim_buf_get_lines(buf, s[1] - 1, last, false)
    add(
      ("\nLast visual selection: lines %d-%d%s"):format(
        s[1],
        e[1],
        last < e[1] and (" (first %d shown)"):format(MAX_SELECTION_LINES) or ""
      )
    )
    add("```" .. ft)
    vim.list_extend(out, lines)
    add("```")
  end

  local diags = vim.diagnostic.get(buf)
  if #diags > 0 then
    table.sort(diags, function(a, b)
      return a.severity < b.severity or (a.severity == b.severity and a.lnum < b.lnum)
    end)
    add(("\nDiagnostics in this file (%d):"):format(#diags))
    for i, d in ipairs(diags) do
      if i > MAX_DIAGNOSTICS then
        add(("  … %d more"):format(#diags - MAX_DIAGNOSTICS))
        break
      end
      add(
        ("  line %d: %s: %s%s"):format(
          d.lnum + 1,
          vim.diagnostic.severity[d.severity],
          (d.message:gsub("\n", " ")),
          d.source and (" (" .. d.source .. ")") or ""
        )
      )
    end
  end

  local unsaved, open = {}, {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      local n = rel(vim.api.nvim_buf_get_name(b))
      if vim.bo[b].modified then
        unsaved[#unsaved + 1] = n
      end
      if b ~= buf then
        open[#open + 1] = n
      end
    end
  end
  if #unsaved > 0 then
    add("\nUnsaved buffers (the files on disk are older than what the user sees): " .. table.concat(unsaved, ", "))
  end
  if #open > 0 then
    add("\nOther open files: " .. table.concat(open, ", "))
  end
  return table.concat(out, "\n")
end

return M
