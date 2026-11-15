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
