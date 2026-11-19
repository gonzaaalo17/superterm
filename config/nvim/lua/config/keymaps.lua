-- Keymaps added on top of LazyVim's: https://www.lazyvim.org/keymaps
-- Rule: LazyVim's defaults win. Only keys LazyVim leaves free are mapped here.
local map = vim.keymap.set

map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "ñ", "~", { desc = "Toggle case" })
map("n", "´", "*", { desc = "Search word under cursor" })

-- Arrows move between windows (Ctrl+h/j/k/l also works, and crosses into tmux panes).
-- In lists and panels (quickfix, :Lazy, :Mason, DBUI…) they keep moving the cursor.
local function arrow(key, wincmd)
  return function()
    if vim.bo.buftype ~= "" then
      return vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
    end
    vim.cmd.wincmd({ wincmd, count = vim.v.count1 })
  end
end
map("n", "<Up>", arrow("<Up>", "k"), { desc = "Window up" })
map("n", "<Down>", arrow("<Down>", "j"), { desc = "Window down" })
map("n", "<Left>", arrow("<Left>", "h"), { desc = "Window left" })
map("n", "<Right>", arrow("<Right>", "l"), { desc = "Window right" })

-- Enter / Alt+Enter: insert [count] blank lines below / above.
-- Only in normal, editable buffers: quickfix, help, pickers… keep their own Enter.
local function blank_lines(offset)
  return function()
    if vim.bo.buftype ~= "" or not vim.bo.modifiable then
      return vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
    end
    local row = vim.fn.line(".") + offset
    local lines = {}
    for _ = 1, vim.v.count1 do
      lines[#lines + 1] = ""
    end
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
  end
end
map("n", "<CR>", blank_lines(0), { desc = "Blank line(s) below" })
map("n", "<M-CR>", blank_lines(-1), { desc = "Blank line(s) above" })

-- Terminal: Ctrl+ñ does what LazyVim's Ctrl+/ does. On a Spanish keyboard "/" is Shift+7,
-- so Ctrl+/ may not reach Neovim; ñ is a key of its own (needs tmux extended-keys, on here).
map({ "n", "t" }, "<C-ñ>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

-- Space ao: hand the current file (or the selected lines) to the project's agent: types an
-- @-reference into opencode's prompt and floats it (bin/dev --send; prefix a hides it).
map({ "n", "x" }, "<leader>ao", function()
  if not vim.env.TMUX then
    return vim.notify("Space ao needs tmux: open the project with `dev`", vim.log.levels.WARN)
  end
  local path = vim.fn.expand("%:.")
  if path == "" then
    return vim.notify("No file in this buffer", vim.log.levels.WARN)
  end
  local ref = "@" .. path
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local a, b = vim.fn.line("v"), vim.fn.line(".")
    ref = ("%s lines %d-%d"):format(ref, math.min(a, b), math.max(a, b))
    vim.cmd("normal! \27") -- leave visual mode, so the selection marks are set for nvim-context
  end
  vim.cmd("silent! update") -- the agent reads the file from disk
  vim.system({ "dev", "--send", ref .. " " })
end, { desc = "Send file/selection to the agent (opencode)" })
