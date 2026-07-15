local M = {}

-- =============================================================================
-- Session Module
-- =============================================================================
-- cursor-agent persists chats under ~/.config/cursor/chats/<wsHash>/<chatId>/
-- with a meta.json ({ title, cwd, createdAtMs, updatedAtMs, hasConversation })
-- and a prompt_history.json (array of user prompts). We read these directly to
-- list/preview sessions and continue them via `cursor-agent --resume <chatId>`.

local config = require("cursor_agent.config")

-- =============================================================================
-- Paths
-- =============================================================================

--- Root directory where cursor-agent stores chats
---@return string
function M.chats_dir()
    -- cursor stores chats in ~/.config/cursor/chats regardless of $XDG on Linux
    local home = vim.env.HOME or vim.loop.os_homedir()
    return home .. "/.config/cursor/chats"
end

--- Read and decode a JSON file, returning nil on failure
---@param path string
---@return table|nil
local function read_json(path)
    if vim.fn.filereadable(path) == 0 then
        return nil
    end
    local content = vim.fn.readfile(path)
    if #content == 0 then
        return nil
    end
    local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if ok then
        return data
    end
    return nil
end

--- Get the prompt history (list of user prompts) for a chat id
---@param chat_id string
---@return table prompts Array of strings (may be empty)
function M.get_prompt_history(chat_id)
    local dir = M.chats_dir()
    local matches = vim.fn.glob(dir .. "/*/" .. chat_id .. "/prompt_history.json", false, true)
    if #matches == 0 then
        return {}
    end
    local data = read_json(matches[1])
    if type(data) == "table" then
        return data
    end
    return {}
end

--- Build a human-readable preview for a session
---@param meta table meta.json contents
---@param chat_id string
---@return string
local function build_preview(meta, chat_id)
    if meta.title and meta.title ~= "" then
        return meta.title
    end
    local prompts = M.get_prompt_history(chat_id)
    for _, p in ipairs(prompts) do
        local trimmed = vim.trim(p or "")
        if trimmed ~= "" then
            return trimmed:sub(1, 60) .. (#trimmed > 60 and "..." or "")
        end
    end
    return "(empty chat)"
end

--- List all sessions for the current working directory (newest first)
---@param all? boolean If true, list sessions from every cwd
---@return table sessions Array of { id, name, mtime, cwd, display }
function M.list_sessions(all)
    local sessions = {}
    local dir = M.chats_dir()
    if vim.fn.isdirectory(dir) == 0 then
        return sessions
    end

    local cwd = config.get_cwd()
    local meta_files = vim.fn.glob(dir .. "/*/*/meta.json", false, true)

    for _, meta_path in ipairs(meta_files) do
        local meta = read_json(meta_path)
        if type(meta) == "table" then
            -- Skip subagent chats — they aren't independently resumable sessions.
            if not meta.isSubagent and (all or meta.cwd == cwd) then
                local chat_dir = vim.fn.fnamemodify(meta_path, ":h")
                local chat_id = vim.fn.fnamemodify(chat_dir, ":t")
                local mtime = meta.updatedAtMs and math.floor(meta.updatedAtMs / 1000)
                    or vim.fn.getftime(meta_path)
                local preview = build_preview(meta, chat_id)
                table.insert(sessions, {
                    id = chat_id,
                    name = preview,
                    mtime = mtime,
                    cwd = meta.cwd,
                    display = os.date("%Y-%m-%d %H:%M", mtime) .. " - " .. preview,
                })
            end
        end
    end

    table.sort(sessions, function(a, b)
        return a.mtime > b.mtime
    end)

    return sessions
end

--- Load a textual preview of a session (its prompt history)
---@param chat_id string
---@return string
function M.load_session_preview(chat_id)
    local prompts = M.get_prompt_history(chat_id)
    if #prompts == 0 then
        return "(no stored prompts for this chat)"
    end
    local lines = { "# Prompt history", "" }
    for i, p in ipairs(prompts) do
        table.insert(lines, string.format("## %d.", i))
        for _, l in ipairs(vim.split(p or "", "\n", { plain = true })) do
            table.insert(lines, l)
        end
        table.insert(lines, "")
    end
    return table.concat(lines, "\n")
end

-- =============================================================================
-- Session State Management
-- =============================================================================

--- Start a new session (id assigned by cursor-agent on next run)
function M.start_new_session()
    config.state.current_session_id = nil
    config.state.current_session_name = nil
end

--- Clear the current session reference
function M.clear_session()
    config.state.current_session_id = nil
    config.state.current_session_name = nil
end

--- Get the session id associated with the current response buffer, if any
---@return string|nil
function M.get_session_from_current_buffer()
    local current_buf = vim.api.nvim_get_current_buf()
    local state = config.state
    if current_buf == state.response_buf
        and state.response_buf
        and vim.api.nvim_buf_is_valid(state.response_buf) then
        return vim.b[state.response_buf].cursor_agent_session_id
    end
    return nil
end

return M
