-- Project-scoped lazydocker / lazysql / dadbod.
--
-- Outside Neovim these tools stay global, exactly as in the shell. Inside Neovim they open on
-- the current project (its git root, or the cwd when there is no repo):
--
--   lazydocker  the compose project(s) whose containers were started from inside the project
--               (from the com.docker.compose.* labels), so a sibling project sharing the folder
--               (e.g. a sandbox stack) is told apart. Standalone containers, images, volumes and
--               networks are always global: lazydocker has no way to filter those.
--   lazysql     <root>/.lazysql.toml if present (lazysql's own format, several connections),
--               else every *DATABASE_URL / *DB_URL in <root>/.env and .env.local,
--               else the global connections (~/.config/lazysql/config.toml).
--   dadbod-ui   the same .env connections, as vim.g.dbs.
local M = {}

local uv = vim.uv

function M.root()
  return LazyVim.root.git()
end

local function float(cmd, cwd)
  return Snacks.terminal(cmd, {
    cwd = cwd,
    -- Esc belongs to the TUI (lazysql/lazydocker use it), not to "leave terminal mode"
    win = { position = "float", width = 0.9, height = 0.9, border = "rounded", keys = { term_normal = false } },
  })
end

-- ── lazydocker ───────────────────────────────────────────────────────────

--- Compose projects with at least one container whose working dir is inside `root`.
---@return {name:string, files:string[]}[]
local function compose_projects(root)
  local fmt = '{{.Label "com.docker.compose.project"}}\t'
    .. '{{.Label "com.docker.compose.project.working_dir"}}\t'
    .. '{{.Label "com.docker.compose.project.config_files"}}'
  local res = vim
    .system({ "docker", "ps", "-a", "--filter", "label=com.docker.compose.project", "--format", fmt }, { text = true })
    :wait()
  if res.code ~= 0 then
    return {}
  end
  local seen, out = {}, {}
  for line in res.stdout:gmatch("[^\n]+") do
    local name, wd, files = line:match("^([^\t]*)\t([^\t]*)\t(.*)$")
    if name and name ~= "" and not seen[name] and (wd == root or vim.startswith(wd, root .. "/")) then
      seen[name] = true
      out[#out + 1] = { name = name, files = vim.split(files, ",", { trimempty = true }) }
    end
  end
  table.sort(out, function(a, b)
    return a.name < b.name
  end)
  return out
end

function M.lazydocker()
  local root = M.root()
  local projects = compose_projects(root)
  local function open(p)
    local cmd = { "lazydocker", "-p", p.name }
    for _, f in ipairs(p.files) do
      vim.list_extend(cmd, { "-f", f })
    end
    float(cmd, root)
  end
  if #projects == 1 then
    return open(projects[1])
  elseif #projects > 1 then
    return vim.ui.select(projects, {
      prompt = "Compose project",
      format_item = function(p)
        return p.name
      end,
    }, function(p)
      if p then
        open(p)
      end
    end)
  end
  -- No containers yet: lazydocker still picks up a compose file in the root on its own.
  float({ "lazydocker" }, root)
end

function M.lazydocker_global()
  float({ "lazydocker" }, vim.env.HOME)
end

-- ── database connections ─────────────────────────────────────────────────

local function read_env(path, vars)
  local f = io.open(path, "r")
  if not f then
    return
  end
  for line in f:lines() do
    line = vim.trim(line):gsub("^export%s+", "")
    local key, val = line:match("^([%w_%.]+)%s*=%s*(.-)%s*$")
    if key then
      local q = val:sub(1, 1)
      if (q == '"' or q == "'") and val:sub(-1) == q and #val >= 2 then
        val = val:sub(2, -2)
      else
        val = val:gsub("%s+#.*$", "")
      end
      if q ~= "'" then -- like dotenv: no expansion inside single quotes
        val = val:gsub("%${([%w_]+)}", function(k)
          return vars[k] or vim.env[k] or ""
        end)
      end
      vars[key] = val
    end
  end
  f:close()
end

local providers = {
  postgres = "postgres",
  postgresql = "postgres",
  pg = "postgres",
  mysql = "mysql",
  mariadb = "mysql",
  sqlite = "sqlite3",
  sqlite3 = "sqlite3",
  file = "sqlite3",
  sqlserver = "sqlserver",
  mssql = "sqlserver",
}

--- Normalises a URL for lazysql and dadbod. nil if the scheme is not supported.
local function parse_url(url, root)
  local scheme = url:match("^(%a[%w+]*):")
  local provider = scheme and providers[scheme:lower()]
  if not provider then
    return nil
  end
  if provider ~= "sqlite3" then
    return { provider = provider, lazysql = url, dadbod = url }
  end
  -- sqlite: lazysql only opens file:<path> (sqlite://… fails), dadbod wants sqlite:<path>
  local path = url:gsub("^%a+:", ""):gsub("^//", "")
  if path:sub(1, 1) ~= "/" then
    path = vim.fs.normalize(root .. "/" .. path)
  end
  return { provider = provider, lazysql = "file:" .. path, dadbod = "sqlite:" .. path }
end

--- Connections declared in the project's .env files.
---@return {name:string, provider:string, lazysql:string, dadbod:string}[]
function M.env_connections(root)
  local vars = {}
  read_env(root .. "/.env", vars)
  read_env(root .. "/.env.local", vars)
  local project, out = vim.fs.basename(root), {}
  for key, val in pairs(vars) do
    if val ~= "" and (key:match("DATABASE_URL$") or key:match("^DB_URL$") or key:match("_DB_URL$")) then
      local c = parse_url(val, root)
      if c then
        c.name = project .. " · " .. key
        out[#out + 1] = c
      end
    end
  end
  table.sort(out, function(a, b)
    return a.name < b.name
  end)
  return out
end

local function toml_str(s)
  return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

function M.lazysql()
  local root = M.root()
  local own = root .. "/.lazysql.toml"
  if uv.fs_stat(own) then
    return float({ "lazysql", "-no-telemetry", "-config", own }, root)
  end
  local conns = M.env_connections(root)
  if #conns == 0 then
    vim.notify(
      "No database in .env or .lazysql.toml: opening the global connections",
      vim.log.levels.INFO,
      { title = "lazysql" }
    )
    return M.lazysql_global()
  end
  -- A throwaway config in Neovim's private temp dir (0700, wiped when Neovim exits), so
  -- passwords stay off the command line. The wrapper also removes it as soon as lazysql ends.
  local cfg = vim.fn.tempname() .. ".toml"
  local lines = {}
  for _, c in ipairs(conns) do
    vim.list_extend(
      lines,
      {
        "[[database]]",
        "Name = " .. toml_str(c.name),
        "Provider = " .. toml_str(c.provider),
        "URL = " .. toml_str(c.lazysql),
        "",
      }
    )
  end
  vim.fn.writefile(lines, cfg)
  uv.fs_chmod(cfg, tonumber("600", 8))
  float({ "sh", "-c", 'lazysql -no-telemetry -config "$1"; rm -f "$1"', "lazysql", cfg }, root)
end

function M.lazysql_global()
  float({ "lazysql", "-no-telemetry" }, vim.env.HOME)
end

--- dadbod-ui: the project's .env connections.
function M.set_dbs()
  local dbs = {}
  for _, c in ipairs(M.env_connections(M.root())) do
    dbs[#dbs + 1] = { name = c.name, url = c.dadbod }
  end
  vim.g.dbs = dbs
end

return M
