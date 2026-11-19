-- Options loaded before lazy.nvim starts. LazyVim's defaults:
-- https://www.lazyvim.org/configuration/general  (only the differences live here)

vim.opt.relativenumber = false
vim.opt.smartcase = false -- searches stay case-insensitive even with capitals

-- Light/dark follows GNOME, like the rest of superterm (lua/tools/flavor.lua)
vim.o.background = require("tools.flavor") == "latte" and "light" or "dark"

-- Spell checking (on in markdown, text and git commits, as LazyVim sets) in English and Spanish.
-- The Spanish dictionary is downloaded by install.sh into ~/.local/share/nvim/site/spell.
vim.opt.spelllang = { "en", "es" }
