local M = {}

-- =============================================================================
-- Session Module
-- =============================================================================
-- Claude Code persists sessions as JSONL transcripts under
-- ~/.claude/projects/<encoded-cwd>/<session-id>.jsonl. Each line is one record;
-- the interesting ones are:
--   {"type":"user","cwd":"..","sessionId":"..","timestamp":"..","message":{"role":"user","content":..}}
--   {"type":"ai-title","sessionId":"..","aiTitle":".."}
-- We read these directly to list/preview sessions and continue them via
-- `claude --resume <session-id>`.

local config = require("claude_code.config")

-- =============================================================================
-- Paths
-- =============================================================================

--- Root directory where claude stores per-project session transcripts
---@return string
function M.projects_dir()
    local home = vim.env.HOME or vim.loop.os_homedir()
    return home .. "/.claude/projects"
end

--- Encode a cwd the way claude names its project directory (path separators and
--- dots become dashes). Used as a fast path; the authoritative cwd check reads
--- the `cwd` field out of the transcript itself.
---@param cwd string
---@return string
function M.encode_cwd(cwd)
    return (cwd:gsub("[/%.]", "-"))
end

-- =============================================================================
-- Transcript reading
-- =============================================================================

--- Decode a JSONL line, returning nil on failure
---@param line string
---@return table|nil
local function decode(line)
    if not line or line == "" then
        return nil
    end
    local ok, data = pcall(vim.json.decode, line)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

--- Extract plain text from a message.content value (string or block array).
--- Skips tool_result / tool_use blocks, which are machine plumbing.
---@param content any
---@return string|nil
local function message_text(content)
    if type(content) == "string" then
        return content
    end
    if type(content) ~= "table" then
        return nil
    end
    local parts = {}
    for _, item in ipairs(content) do
        if type(item) == "table" and item.type == "text" and item.text then
            table.insert(parts, item.text)
        end
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, "\n")
end

--- Read the head of a transcript to learn its cwd, title and first prompt.
---@param path string
---@return table|nil info { cwd, title, preview }
local function read_transcript_head(path)
    local ok, lines = pcall(vim.fn.readfile, path, "", 60)
    if not ok or type(lines) ~= "table" then
        return nil
    end

    local info = {}
    for _, line in ipairs(lines) do
        local data = decode(line)
        if data then
            if not info.cwd and data.cwd then
                info.cwd = data.cwd
            end
            if data.type == "ai-title" and data.aiTitle then
                info.title = data.aiTitle
            end
            if not info.preview and data.type == "user" and not data.isSidechain and not data.isMeta then
                local text = message_text(data.message and data.message.content)
                if text then
                    text = vim.trim(text)
                    if text ~= "" and not text:match("^<") then
                        info.preview = text
                    end
                end
            end
        end
    end

    if not info.cwd then
        return nil
    end
    return info
end

--- Get the user prompts recorded in a session transcript
---@param path string
---@return string[] prompts
local function read_prompt_history(path)
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok or type(lines) ~= "table" then
        return {}
    end
    local prompts = {}
    for _, line in ipairs(lines) do
        local data = decode(line)
        if data and data.type == "user" and not data.isSidechain and not data.isMeta then
            local text = message_text(data.message and data.message.content)
            if text then
                text = vim.trim(text)
                if text ~= "" and not text:match("^<") then
                    table.insert(prompts, text)
                end
            end
        end
    end
    return prompts
end

-- =============================================================================
-- Listing
-- =============================================================================

--- Candidate transcript files: the encoded directory for `cwd` when it exists,
--- otherwise every project directory (so a differently-encoded path is still
--- found; each file's own `cwd` field is what actually filters the list).
---@param all boolean
---@return string[] paths
local function transcript_paths(all)
    local root = M.projects_dir()
    if vim.fn.isdirectory(root) == 0 then
        return {}
    end
    if not all then
        local dir = root .. "/" .. M.encode_cwd(config.get_cwd())
        if vim.fn.isdirectory(dir) == 1 then
            return vim.fn.glob(dir .. "/*.jsonl", false, true)
        end
    end
    return vim.fn.glob(root .. "/*/*.jsonl", false, true)
end

--- List sessions for the current working directory (newest first)
---@param all? boolean If true, list sessions from every cwd
---@return table sessions Array of { id, name, mtime, cwd, display }
function M.list_sessions(all)
    local sessions = {}
    local cwd = config.get_cwd()

    for _, path in ipairs(transcript_paths(all)) do
        local info = read_transcript_head(path)
        if info and (all or info.cwd == cwd) then
            local id = vim.fn.fnamemodify(path, ":t:r")
            local mtime = vim.fn.getftime(path)
            local preview = info.title or info.preview or "(empty chat)"
            preview = preview:gsub("[\r\n]+", " ")
            if #preview > 60 then
                preview = preview:sub(1, 60) .. "..."
            end
            table.insert(sessions, {
                id = id,
                name = preview,
                mtime = mtime,
                cwd = info.cwd,
                path = path,
                display = os.date("%Y-%m-%d %H:%M", mtime) .. " - " .. preview,
            })
        end
    end

    table.sort(sessions, function(a, b)
        return a.mtime > b.mtime
    end)

    return sessions
end

--- Locate a session's transcript by id
---@param session_id string
---@return string|nil path
function M.transcript_path(session_id)
    local root = M.projects_dir()
    local direct = root .. "/" .. M.encode_cwd(config.get_cwd()) .. "/" .. session_id .. ".jsonl"
    if vim.fn.filereadable(direct) == 1 then
        return direct
    end
    local matches = vim.fn.glob(root .. "/*/" .. session_id .. ".jsonl", false, true)
    if #matches > 0 then
        return matches[1]
    end
    return nil
end

--- Load a textual preview of a session (its prompt history)
---@param session_id string
---@return string
function M.load_session_preview(session_id)
    local path = M.transcript_path(session_id)
    if not path then
        return "(no transcript found for this session)"
    end
    local prompts = read_prompt_history(path)
    if #prompts == 0 then
        return "(no stored prompts for this session)"
    end
    local lines = { "# Prompt history", "" }
    for i, p in ipairs(prompts) do
        table.insert(lines, string.format("## %d.", i))
        for _, l in ipairs(vim.split(p, "\n", { plain = true })) do
            table.insert(lines, l)
        end
        table.insert(lines, "")
    end
    return table.concat(lines, "\n")
end

-- =============================================================================
-- Session State Management
-- =============================================================================

--- Start a new session (id assigned by claude on the next run)
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
        return vim.b[state.response_buf].claude_code_session_id
    end
    return nil
end

return M
