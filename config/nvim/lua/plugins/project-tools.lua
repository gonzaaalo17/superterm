-- lazygit / lazydocker / lazysql / dadbod on the current project. Logic: lua/tools/project.lua
--
--   <leader>gg  lazygit (project root)        LazyVim default · <leader>gG in the cwd
--   <leader>od  lazydocker (project)          <leader>oD global
--   <leader>os  lazysql (project)             <leader>oS global
--   <leader>D   dadbod-ui (project .env)      LazyVim default (sql extra)
local project = function()
  return require("tools.project")
end

return {
  {
    "folke/snacks.nvim",
    init = function()
      -- lazygit inside Neovim: superterm's config, then Snacks' file (edits open in this
      -- Neovim via nvim-remote), then superterm's Catppuccin theme last so it wins.
      local dir = vim.fn.expand("~/.config/lazygit")
      local flavor = require("tools.flavor")
      local snacks_theme = vim.fs.normalize(vim.fn.stdpath("cache") .. "/lazygit-theme.yml")
      local files = vim.tbl_filter(function(f)
        return f == snacks_theme or vim.uv.fs_stat(f) ~= nil
      end, { dir .. "/config.yml", snacks_theme, dir .. "/theme-" .. flavor .. ".yml" })
      vim.env.LG_CONFIG_FILE = table.concat(files, ",")
    end,
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>o", group = "tools (project)", icon = { icon = "󰒓 ", color = "orange" } } } },
  },
  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>od",
        function()
          project().lazydocker()
        end,
        desc = "Lazydocker (project)",
      },
      {
        "<leader>oD",
        function()
          project().lazydocker_global()
        end,
        desc = "Lazydocker (global)",
      },
      {
        "<leader>os",
        function()
          project().lazysql()
        end,
        desc = "Lazysql (project)",
      },
      {
        "<leader>oS",
        function()
          project().lazysql_global()
        end,
        desc = "Lazysql (global)",
      },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    init = function()
      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        group = vim.api.nvim_create_augroup("project_dbs", { clear = true }),
        callback = function()
          project().set_dbs()
        end,
      })
    end,
  },
}
