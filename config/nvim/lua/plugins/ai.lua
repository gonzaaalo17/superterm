-- Local AI through Ollama: inline completion (minuet-ai) and chat / inline edits (CodeCompanion).
-- Models per machine: ~/.config/ai/config.json, or :AIModel. See lua/tools/ai.lua.
--
--   Tab          accept the grey suggestion (after snippets, as in LazyVim's AI extras)
--   Alt+a        accept one line · Alt+] / Alt+[ next / previous (or ask for one) · Alt+e dismiss
--   <leader>aa   chat (toggle)        <leader>ai  inline edit / generate (also on a selection)
--   <leader>ap   actions              <leader>ac  add selection to the chat
--   <leader>am   pick models          <leader>at  toggle completion while typing
local ai = function()
  return require("tools.ai")
end

return {
  -- ── Inline completion ──────────────────────────────────────────────────
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      return {
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 6000, -- characters around the cursor (~1.5k tokens): keeps it fast
        request_timeout = 3,
        throttle = 800,
        debounce = 300,
        provider_options = {
          openai_fim_compatible = {
            name = "Ollama",
            api_key = "TERM", -- Ollama needs no key; minuet wants the name of a set env var
            end_point = ai().host() .. "/v1/completions",
            model = ai().model("complete"),
            stream = true,
            optional = { max_tokens = 64, top_p = 0.9, stop = { "\n\n\n" } },
          },
        },
        virtualtext = {
          auto_trigger_ft = { "*" },
          auto_trigger_ignore_ft = { "snacks_picker_input", "codecompanion", "TelescopePrompt", "minifiles" },
          keymap = {
            accept_line = "<A-a>",
            next = "<A-]>",
            prev = "<A-[>",
            dismiss = "<A-e>",
          },
          show_on_completion_menu = false,
        },
      }
    end,
    config = function(_, opts)
      require("minuet").setup(opts)
      -- minuet enables auto-trigger on FileType; buffers opened before this lazy-load
      -- already had theirs, so enable it on them here.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local bo = vim.bo[buf]
        if
          vim.api.nvim_buf_is_loaded(buf)
          and bo.buftype == ""
          and bo.filetype ~= ""
          and not vim.tbl_contains(opts.virtualtext.auto_trigger_ignore_ft, bo.filetype)
        then
          vim.b[buf].minuet_virtual_text_auto_trigger = true
        end
      end
      ai().on_change("complete", function(model)
        require("minuet").config.provider_options.openai_fim_compatible.model = model
      end)
      -- Tab accepts, through LazyVim's blink <Tab> chain (snippet jump first, then AI)
      LazyVim.cmp.actions.ai_accept = function()
        local vt = require("minuet.virtualtext").action
        if vt.is_visible() then
          LazyVim.create_undo()
          vt.accept()
          return true
        end
      end
    end,
    keys = {
      {
        "<leader>at",
        function()
          require("minuet.virtualtext").action.toggle_auto_trigger()
        end,
        desc = "Toggle AI completion (buffer)",
      },
    },
  },

  -- ── Chat and inline edits ──────────────────────────────────────────────
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    opts = function()
      local function ollama()
        return require("codecompanion.adapters").extend("ollama", {
          env = { url = ai().host() },
          schema = {
            -- read at the start of each chat, so :AIModel applies to the next one
            model = {
              default = function()
                return ai().model("chat")
              end,
            },
            num_ctx = {
              default = function()
                return ai().chat_ctx()
              end,
            },
            keep_alive = { default = "15m" },
            -- Low temperature: steadier code and tool calls (qwen3-coder at its default 0.7
            -- sometimes writes a tool call as text, which Ollama then fails to parse).
            temperature = { default = 0.2 },
          },
        })
      end
      -- Read-only tools run without asking inside the project; outside it (~/.ssh, other
      -- repos…) they ask. Edits are shown as a diff to accept, commands always ask.
      local function outside_cwd(tool)
        local args = tool.args or {}
        local path = args.filepath or args.path or args.directory
        if not path or path == "" then
          return false
        end
        local abs = vim.fs.normalize(vim.fs.abspath(path))
        local cwd = vim.fs.normalize(vim.uv.cwd())
        return not (abs == cwd or vim.startswith(abs, cwd .. "/"))
      end
      local read_only = { opts = { require_approval_before = outside_cwd } }
      return {
        adapters = { http = { opts = { show_presets = false }, ollama = ollama } },
        interactions = {
          chat = {
            adapter = "ollama",
            tools = {
              read_file = read_only,
              grep_search = read_only,
              file_search = read_only,
            },
          },
          inline = { adapter = "ollama" },
          cmd = { adapter = "ollama" },
          background = { adapter = "ollama" },
        },
        opts = { language = "Spanish" },
      }
    end,
    config = function(_, opts)
      require("codecompanion").setup(opts)
      -- Project rule files (AGENTS.md, CLAUDE.md, .cursorrules… in the repo) are useful context;
      -- the global ~/.claude/CLAUDE.md is Claude Code's own instructions, not this chat's.
      local rules = require("codecompanion.config").rules.default
      rules.files = vim.tbl_filter(function(f)
        local path = type(f) == "table" and f.path or f
        return not vim.startswith(path, "~/")
      end, rules.files)
      -- @{agent}: local models call tools reliably one at a time with nothing written before
      -- the call; several calls in one reply, or text first, is when Ollama's parser drops one
      -- and the agent loop stops halfway.
      local agent = require("codecompanion.config").interactions.chat.tools.groups.agent
      local prompt = agent.system_prompt
      agent.system_prompt = function(...)
        return prompt(...):gsub("Prefer calling multiple tools in parallel when possible%.\n", "")
          .. "\n<localModel>\nCall exactly one tool per response and wait for its result. "
          .. "Do not write anything before a tool call; explain after the results.\n</localModel>"
      end
    end,
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat" },
      { "<leader>ai", ":CodeCompanion ", mode = { "n", "v" }, desc = "AI inline" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to AI chat" },
    },
  },

  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>am",
        function()
          ai().pick()
        end,
        desc = "AI models (complete / chat)",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>a", group = "ai (local)", mode = { "n", "v" } } } },
  },
}
