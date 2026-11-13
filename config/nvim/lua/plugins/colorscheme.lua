-- Catppuccin, same as the rest of superterm: Mocha/Latte following GNOME (see
-- config/options.lua) and a transparent background, so Ghostty's opacity and blur show through.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto",
      background = { light = "latte", dark = "mocha" },
      transparent_background = true,
      float = { transparent = true, solid = false },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- Not the string "catppuccin": Neovim 0.12 ships its own runtime/colors/catppuccin.vim,
      -- which would win over the plugin and ignore the options above.
      colorscheme = function()
        require("catppuccin").load()
      end,
    },
  },
}
