local M = {}

-- =============================================================================
-- Commands Module
-- =============================================================================
-- User commands and keymaps for cursor_agent.

local config = require("cursor_agent.config")

--- Get the source file from the current buffer (relative to cwd when possible)
---@return string|nil
local function get_source_file()
    local bufname = vim.fn.expand("%")
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    if bufname == "" or buftype ~= "" or filetype == "netrw" or filetype == "oil" then
        return nil
    end
    if vim.fn.filereadable(bufname) == 0 then
        return nil
    end

    local full_path = vim.fn.fnamemodify(bufname, ":p")
    local cwd = vim.fn.getcwd()
    if not cwd:match("/$") then
        cwd = cwd .. "/"
    end
    if full_path:sub(1, #cwd) == cwd then
        return full_path:sub(#cwd + 1)
    end
    return bufname
end

M.get_source_file = get_source_file

--- Register user commands with both long (Cursor*) and short (CA*) aliases
---@param cursor_agent table Main module (M from init.lua)
local function setup_commands(cursor_agent)
    local function cmd(names, fn, cmd_opts)
        for _, name in ipairs(names) do
            vim.api.nvim_create_user_command(name, fn, cmd_opts or { nargs = 0 })
        end
    end

    cmd({ "CursorAgent", "CA" }, function()
        cursor_agent.Open(nil, nil, get_source_file())
    end)

    cmd({ "CursorAgentWSelection", "CAWSelection" }, function()
        local source_file = get_source_file()
        local mode = vim.fn.mode()
        if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
            cursor_agent.Open(nil, nil, source_file)
            return
        end
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")
        local selection_lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
        cursor_agent.Open(selection_lines, vim.bo.filetype, source_file)
    end)

    cmd({ "CursorAgentModel", "CAModel" }, function()
        cursor_agent.SelectModel()
    end)

    cmd({ "CursorAgentSessions", "CASessions" }, function()
        cursor_agent.SelectSession()
    end)

    cmd({ "CursorAgentCLI", "CACLI" }, function()
        cursor_agent.ToggleCLI()
    end)

    cmd({ "CursorAgentNew", "CANew" }, function()
        cursor_agent.NewSession()
    end)

    cmd({ "CursorAgentStop", "CAStop" }, function()
        cursor_agent.StopAll()
    end)

    local mode_opts = {
        nargs = "?",
        complete = function() return config.MODES end,
        desc = "Get, set or cycle CursorAgent mode (agent/plan/ask/quick)",
    }
    cmd({ "CursorAgentMode", "CAMode" }, function(opts)
        local arg = opts.args and opts.args ~= "" and opts.args or nil
        if arg then
            cursor_agent.SetMode(arg)
        else
            cursor_agent.SetMode() -- cycle
        end
    end, mode_opts)
end

--- Register default keymaps
---@param user_config table
local function setup_keymaps(user_config)
    if not user_config.keymaps.enable_default then
        return
    end
    local keymap = user_config.keymaps.open_prompt
    vim.keymap.set("n", keymap, "<Cmd>CursorAgent<CR>",
        { noremap = true, silent = true, desc = "Open CursorAgent prompt" })
    vim.keymap.set("v", keymap, "<Cmd>CursorAgentWSelection<CR>",
        { noremap = true, silent = true, desc = "Open CursorAgent with selection" })
end

--- Setup commands and keymaps
---@param cursor_agent table
---@param user_config table
function M.setup(cursor_agent, user_config)
    setup_commands(cursor_agent)
    setup_keymaps(user_config)
end

return M
