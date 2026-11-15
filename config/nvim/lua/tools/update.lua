-- Unattended update of everything Neovim installs itself, for `install.sh --update`
-- (which the weekly update-all timer runs):
--
--   nvim --headless "+lua require('tools.update').run()"
--
--   1. plugins       :Lazy update — rewrites lazy-lock.json in the repo. Review and commit it;
--                    if an update breaks something: git checkout the lockfile, :Lazy restore.
--   2. parsers       treesitter parsers, to the revisions the updated nvim-treesitter pins
--   3. Mason tools   LSPs, formatters, linters with a newer version in the registry
--
-- Neovim itself is the Fedora package (dnf). Exits 1 if any step failed.
local M = {}

local failed = {}

local function log(msg)
  io.stdout:write(msg .. "\n")
end

local function wait(cond, ms)
  return vim.wait(ms, cond, 200)
end

local function plugins()
  require("lazy").update({ wait = true, show = false })
  for _, p in pairs(require("lazy.core.config").plugins) do
    if p._.has_errors then
      failed[#failed + 1] = "plugin " .. p.name
    end
  end
  log("  plugins updated")
end

local function parsers()
  local ok, ts = pcall(require, "nvim-treesitter")
  if not ok then
    return
  end
  local done = ts.update():wait(600000)
  if done == false then
    failed[#failed + 1] = "treesitter parsers"
  end
  log("  treesitter parsers updated")
end

local function mason()
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end
  local refreshed = false
  registry.update(function(success)
    refreshed = true
    if not success then
      failed[#failed + 1] = "mason registry"
    end
  end)
  if not wait(function()
    return refreshed
  end, 120000) then
    failed[#failed + 1] = "mason registry (timeout)"
    return
  end
  local pending = 0
  for _, pkg in ipairs(registry.get_installed_packages()) do
    local cur, latest = pkg:get_installed_version(), pkg:get_latest_version()
    if cur ~= latest then
      pending = pending + 1
      log(("  mason: %s %s → %s"):format(pkg.name, cur or "?", latest))
      pkg:install({ version = latest }, function(success)
        pending = pending - 1
        if not success then
          failed[#failed + 1] = "mason " .. pkg.name
        end
      end)
    end
  end
  if not wait(function()
    return pending == 0
  end, 900000) then
    failed[#failed + 1] = "mason (timeout)"
  end
  log("  mason tools up to date")
end

function M.run()
  for _, step in ipairs({ plugins, parsers, mason }) do
    local ok, err = pcall(step)
    if not ok then
      failed[#failed + 1] = tostring(err)
    end
  end
  if #failed > 0 then
    log("  failed: " .. table.concat(failed, ", "))
    vim.cmd("cquit 1")
  end
  vim.cmd("qall!")
end

return M
