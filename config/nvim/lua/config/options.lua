-- Options loaded before lazy.nvim starts. LazyVim's defaults:
-- https://www.lazyvim.org/configuration/general  (only the differences live here)

vim.opt.relativenumber = false
vim.opt.smartcase = false -- searches stay case-insensitive even with capitals

-- Light/dark follows GNOME, like the rest of superterm (lua/tools/flavor.lua)
vim.o.background = require("tools.flavor") == "latte" and "light" or "dark"
