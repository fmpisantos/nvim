-- cursor_agent: local Neovim integration for the `cursor-agent` CLI.
--
-- Mirrors the opencode.nvim workflow (prompt window, streaming responses,
-- model/mode/session selection) but targets Cursor's agent CLI. This plugin is
-- entirely local (no remote src), so it is set up directly on load. Telescope
-- is only required lazily inside the pickers, so setup here is safe and cheap.
--
-- Commands: :CursorAgent/:CA, :CAModel, :CAMode, :CASessions, :CACLI,
--           :CANew, :CAStop  (and their :CursorAgent* long forms)
-- Default keymap: <leader>ca (normal + visual)

local ok, cursor_agent = pcall(require, "cursor_agent")
if ok then
    cursor_agent.setup({
        -- timeout_ms = -1,          -- disable the hard timeout (default)
        -- mode = "agent",           -- "agent" | "plan" | "ask" | "quick"
        -- force = true,             -- run every tool call headlessly (--force)
        -- keymaps = { open_prompt = "<leader>ca" },
    })
else
    vim.notify("cursor_agent failed to load: " .. tostring(cursor_agent), vim.log.levels.ERROR)
end

return {}
