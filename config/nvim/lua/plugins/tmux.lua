-- Ctrl+h/j/k/l moves between nvim windows and tmux panes alike.
-- The tmux side is the vim-tmux-navigator plugin in config/tmux/tmux.conf.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
