-- claude_code: local Neovim integration for the `claude` CLI (Claude Code).
--
-- Mirrors the opencode.nvim workflow (prompt window, streaming responses,
-- model/mode/session selection). This plugin is entirely local (no remote src),
-- so it is set up directly on load. Telescope is only required lazily inside
-- the pickers, so setup here is safe and cheap.
--
-- Commands: :ClaudeCode/:CA, :CAModel, :CAMode, :CASessions, :CACLI,
--           :CANew, :CAStop  (and their :ClaudeCode* long forms)
-- Default keymap: <leader>ca (normal + visual)

local ok, claude_code = pcall(require, "claude_code")
if ok then
    claude_code.setup({
        -- timeout_ms = -1,          -- disable the hard timeout (default)
        -- mode = "agent",           -- "agent" | "plan" | "ask" | "quick"
        -- force = true,             -- agent mode runs with --permission-mode bypassPermissions
        -- keymaps = { open_prompt = "<leader>ca" },
    })
else
    vim.notify("claude_code failed to load: " .. tostring(claude_code), vim.log.levels.ERROR)
end

return {}
