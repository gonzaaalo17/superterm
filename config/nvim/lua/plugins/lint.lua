-- markdownlint (from LazyVim's markdown extra) with lint/.markdownlint-cli2.yaml as the base
-- config, so long lines are not flagged. Projects with their own markdownlint config keep it.
local base = vim.fn.stdpath("config") .. "/lint/.markdownlint-cli2.yaml"

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = { args = { "--config", base, "-" } },
      },
    },
  },
}
