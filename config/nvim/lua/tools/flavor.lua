-- Catppuccin flavour for the current GNOME mode, like the rest of superterm: the shell exports
-- CATPPUCCIN_FLAVOR (home/.bashrc.d/10-env.sh); outside a shell, ask GNOME directly.
local flavor = vim.env.CATPPUCCIN_FLAVOR
if flavor ~= "latte" and flavor ~= "mocha" then
  local res = vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait()
  flavor = (res.code == 0 and res.stdout:find("light")) and "latte" or "mocha"
end
return flavor
