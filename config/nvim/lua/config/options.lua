-- Options loaded before lazy.nvim starts. LazyVim's defaults:
-- https://www.lazyvim.org/configuration/general  (only the differences live here)

vim.opt.relativenumber = false
vim.opt.smartcase = false -- searches stay case-insensitive even with capitals

-- Light/dark follows GNOME, like the rest of superterm. The shell exports
-- CATPPUCCIN_FLAVOR (home/.bashrc.d/10-env.sh); outside a shell, ask GNOME directly.
local flavor = vim.env.CATPPUCCIN_FLAVOR
if not flavor or flavor == "" then
  local scheme = vim.fn.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" })
  flavor = (vim.v.shell_error == 0 and scheme:find("light")) and "latte" or "mocha"
end
vim.o.background = flavor == "latte" and "light" or "dark"
