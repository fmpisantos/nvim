local M = {}

-- =============================================================================
-- Commands Module
-- =============================================================================
-- User commands and keymaps for claude_code.

local config = require("claude_code.config")

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

--- Register user commands with both long (ClaudeCode*) and short (CA*) aliases
---@param claude_code table Main module (M from init.lua)
local function setup_commands(claude_code)
    local function cmd(names, fn, cmd_opts)
        for _, name in ipairs(names) do
            vim.api.nvim_create_user_command(name, fn, cmd_opts or { nargs = 0 })
        end
    end

    cmd({ "ClaudeCode", "CA" }, function()
        claude_code.Open(nil, nil, get_source_file())
    end)

    cmd({ "ClaudeCodeWSelection", "CAWSelection" }, function()
        local source_file = get_source_file()
        local mode = vim.fn.mode()
        if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
            claude_code.Open(nil, nil, source_file)
            return
        end
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")
        local selection_lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
        claude_code.Open(selection_lines, vim.bo.filetype, source_file)
    end)

    cmd({ "ClaudeCodeModel", "CAModel" }, function()
        claude_code.SelectModel()
    end)

    cmd({ "ClaudeCodeSessions", "CASessions" }, function()
        claude_code.SelectSession()
    end)

    cmd({ "ClaudeCodeCLI", "CACLI" }, function()
        claude_code.ToggleCLI()
    end)

    cmd({ "ClaudeCodeNew", "CANew" }, function()
        claude_code.NewSession()
    end)

    cmd({ "ClaudeCodeStop", "CAStop" }, function()
        claude_code.StopAll()
    end)

    local mode_opts = {
        nargs = "?",
        complete = function() return config.MODES end,
        desc = "Get, set or cycle ClaudeCode mode (agent/plan/ask/quick)",
    }
    cmd({ "ClaudeCodeMode", "CAMode" }, function(opts)
        local arg = opts.args and opts.args ~= "" and opts.args or nil
        if arg then
            claude_code.SetMode(arg)
        else
            claude_code.SetMode() -- cycle
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
    vim.keymap.set("n", keymap, "<Cmd>ClaudeCode<CR>",
        { noremap = true, silent = true, desc = "Open ClaudeCode prompt" })
    vim.keymap.set("v", keymap, "<Cmd>ClaudeCodeWSelection<CR>",
        { noremap = true, silent = true, desc = "Open ClaudeCode with selection" })
end

--- Setup commands and keymaps
---@param claude_code table
---@param user_config table
function M.setup(claude_code, user_config)
    setup_commands(claude_code)
    setup_keymaps(user_config)
end

return M
