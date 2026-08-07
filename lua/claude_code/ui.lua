local M = {}

-- =============================================================================
-- UI Module
-- =============================================================================
-- Windows, buffers and titles for claude_code.

local config = require("claude_code.config")
local utils = require("claude_code.utils")

-- =============================================================================
-- Response Buffer Management
-- =============================================================================

--- Create or reuse the response buffer in a vertical split
---@param name string Buffer name
---@param clear boolean Whether to clear the buffer
---@return number buf
---@return number win
function M.create_response_split(name, clear)
    local state = config.state

    if state.response_buf and vim.api.nvim_buf_is_valid(state.response_buf) then
        local wins = vim.fn.win_findbuf(state.response_buf)
        if #wins > 0 then
            state.response_win = wins[1]
            vim.api.nvim_set_current_win(state.response_win)
        else
            vim.cmd("vsplit")
            state.response_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(state.response_win, state.response_buf)
        end

        vim.wo[state.response_win].wrap = state.user_config.response_buffer.wrap

        if clear then
            vim.api.nvim_buf_set_lines(state.response_buf, 0, -1, false, {})
        end

        return state.response_buf, state.response_win
    end

    state.response_buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("vsplit")
    state.response_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(state.response_win, state.response_buf)

    vim.bo[state.response_buf].buftype = "nofile"
    vim.bo[state.response_buf].bufhidden = "hide"
    vim.bo[state.response_buf].filetype = "markdown"
    vim.api.nvim_buf_set_name(state.response_buf, name)

    local autocmd_group = vim.api.nvim_create_augroup("ClaudeCode_NoSave_" .. state.response_buf, { clear = true })
    vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", "BufUnload", "VimLeavePre" }, {
        group = autocmd_group,
        buffer = state.response_buf,
        callback = function()
            if vim.api.nvim_buf_is_valid(state.response_buf) then
                vim.bo[state.response_buf].modified = false
            end
        end,
    })

    vim.wo[state.response_win].wrap = state.user_config.response_buffer.wrap
    vim.b[state.response_buf].claude_code_session_id = state.current_session_id

    vim.keymap.set("n", "q", function()
        if state.response_win and vim.api.nvim_win_is_valid(state.response_win) then
            vim.api.nvim_win_close(state.response_win, false)
            state.response_win = nil
        end
    end, { buffer = state.response_buf, noremap = true, silent = true, desc = "Close ClaudeCode response" })

    return state.response_buf, state.response_win
end

--- Toggle the response buffer visibility
function M.toggle_response_buffer()
    local state = config.state

    if not state.response_buf or not vim.api.nvim_buf_is_valid(state.response_buf) then
        vim.notify("No ClaudeCode chat active. Use <leader>ca to start one.", vim.log.levels.INFO)
        return
    end

    local wins = vim.fn.win_findbuf(state.response_buf)
    if #wins > 0 then
        vim.api.nvim_win_close(wins[1], false)
        state.response_win = nil
    else
        vim.cmd("vsplit")
        state.response_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(state.response_win, state.response_buf)
        vim.wo[state.response_win].wrap = state.user_config.response_buffer.wrap
    end
end

-- =============================================================================
-- Titles
-- =============================================================================

--- Build the title for the prompt window
---@param content? string Prompt content to inspect for mode keywords
---@param session_id? string Session id to display
---@return string
function M.get_window_title(content, session_id)
    local mode = config.get_mode()

    if content then
        local _, mode_override = utils.parse_mode_keywords(content)
        if mode_override then
            mode = mode_override
        end
    end

    local title = " ClaudeCode [" .. mode .. "] [" .. config.get_model_display() .. "]"
    if session_id then
        local display = #session_id > 8 and session_id:sub(1, 8) .. "..." or session_id
        title = title .. " [" .. display .. "]"
    end
    return title .. " "
end

-- =============================================================================
-- Auto-reload Setup
-- =============================================================================

--- Reload buffers when their files change on disk (the agent edits files)
function M.setup_auto_reload()
    vim.o.autoread = true

    local augroup = vim.api.nvim_create_augroup("ClaudeCodeAutoReload", { clear = true })

    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
        group = augroup,
        pattern = "*",
        callback = function()
            if vim.fn.getcmdwintype() == "" then
                pcall(vim.cmd, "checktime")
            end
        end,
    })

    vim.api.nvim_create_autocmd("FileChangedShellPost", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
        end,
    })
end

return M
