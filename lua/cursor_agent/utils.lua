local M = {}

-- =============================================================================
-- Utilities Module
-- =============================================================================
-- Shared helpers for cursor_agent.

local config = require("cursor_agent.config")

-- =============================================================================
-- File Utilities
-- =============================================================================

--- Check if a file path exists (handles absolute and cwd-relative paths)
---@param filepath string
---@return boolean
function M.file_exists(filepath)
    if vim.fn.filereadable(filepath) == 1 then
        return true
    end
    if not filepath:match("^[/~]") then
        local full_path = config.get_cwd() .. "/" .. filepath
        if vim.fn.filereadable(full_path) == 1 then
            return true
        end
    end
    return false
end

--- Read a cwd-relative or absolute file's contents as a list of lines.
---@param filepath string
---@return string[]|nil lines
function M.read_referenced_file(filepath)
    local resolved = filepath
    if vim.fn.filereadable(resolved) ~= 1 then
        if not filepath:match("^[/~]") then
            local full_path = config.get_cwd() .. "/" .. filepath
            if vim.fn.filereadable(full_path) == 1 then
                resolved = full_path
            else
                return nil
            end
        else
            return nil
        end
    end
    local ok, lines = pcall(vim.fn.readfile, resolved)
    if not ok then
        return nil
    end
    return lines
end

-- =============================================================================
-- String Utilities
-- =============================================================================

--- Sanitize a string to a single line (strip newlines) for buffer display
---@param str string|nil
---@return string
function M.sanitize_line(str)
    if not str then
        return ""
    end
    return (str:gsub("[\r\n]+", " "))
end

--- Check if content contains a session reference #session(<id>)
---@param content string
---@return boolean
function M.has_session_reference(content)
    return content:match("#session%(([^)]+)%)") ~= nil
end

--- Extract session id from a prompt, returning the cleaned prompt too
---@param prompt string
---@return string prompt Prompt without the session tag
---@return string|nil session_id
function M.extract_session_from_prompt(prompt)
    local session_id = prompt:match("#session%(([^)]+)%)")
    if session_id then
        prompt = prompt:gsub("#session%([^)]+%)%s*", ""):gsub("%s*#session%([^)]+%)", "")
    end
    return prompt, session_id
end

--- Parse leading mode keywords / tags from the prompt content.
--- Recognizes: agent, plan, ask as leading words and #agent, #plan, #ask tags.
---@param content string
---@return string content_without_keywords
---@return string|nil mode "agent" | "plan" | "ask"
function M.parse_mode_keywords(content)
    local remaining = content
    local mode = nil
    local found = true

    while found do
        found = false
        for _, m in ipairs(config.MODES) do
            if remaining:match("^" .. m .. "%s") or remaining:match("^" .. m .. "$") then
                mode = m
                remaining = remaining:gsub("^" .. m .. "%s*", "")
                found = true
                break
            end
        end
    end

    -- Tag syntax anywhere in the string overrides leading keywords.
    -- `%f[%W]` is a frontier pattern so "#agentic" is not matched as "#agent".
    for _, m in ipairs(config.MODES) do
        if remaining:match("#" .. m .. "%f[%W]") then
            mode = m
            remaining = remaining:gsub("#" .. m .. "%f[%W]%s*", ""):gsub("%s*#" .. m .. "%f[%W]", "")
        end
    end

    return remaining, mode
end

--- Strip all plugin-specific markers from a prompt (session/mode/buffer tags)
---@param prompt string
---@return string
function M.strip_prompt_markers(prompt)
    if not prompt then return "" end
    local cleaned = prompt
    cleaned = cleaned:gsub("#session%([^)]+%)", "")
    for _, m in ipairs(config.MODES) do
        cleaned = cleaned:gsub("#" .. m .. "%f[%W]", "")
    end
    cleaned = cleaned:gsub("#buffer%f[%W]", ""):gsub("#buf%f[%W]", "")
    cleaned = cleaned:gsub("%s+", " ")
    return vim.trim(cleaned)
end

-- =============================================================================
-- Quick Mode
-- =============================================================================

--- Collect unique, existing @-referenced file paths from a prompt.
--- Handles both bare (@path) and backtick-wrapped (`@path`) references.
---@param prompt string
---@return string[] paths
function M.collect_file_references(prompt)
    local seen = {}
    local paths = {}
    for path in prompt:gmatch("@([%w%._%-/]+)") do
        if not seen[path] and M.file_exists(path) then
            seen[path] = true
            table.insert(paths, path)
        end
    end
    return paths
end

--- Build a "quick" mode prompt: the original prompt plus a preamble and the
--- inlined contents of every referenced file, so the agent can answer without
--- exploring the project.
---@param prompt string
---@return string quick_prompt
---@return number inlined_count
function M.build_quick_prompt(prompt)
    local paths = M.collect_file_references(prompt)

    local parts = { config.QUICK_MODE_PREAMBLE, "", prompt }

    local inlined = 0
    if #paths > 0 then
        table.insert(parts, "")
        table.insert(parts, "## Referenced file contents")
        for _, path in ipairs(paths) do
            local lines = M.read_referenced_file(path)
            if lines then
                inlined = inlined + 1
                local ext = path:match("%.([%w]+)$") or ""
                table.insert(parts, "")
                table.insert(parts, "### @" .. path)
                table.insert(parts, "```" .. ext)
                vim.list_extend(parts, lines)
                table.insert(parts, "```")
            end
        end
    end

    return table.concat(parts, "\n"), inlined
end

-- =============================================================================
-- Display Utilities
-- =============================================================================

--- Append a stderr block to display lines
---@param display_lines table
---@param stderr_output table
function M.append_stderr_block(display_lines, stderr_output)
    if #stderr_output == 0 then
        return
    end
    table.insert(display_lines, "")
    table.insert(display_lines, "**stderr output:**")
    table.insert(display_lines, "```")
    for _, line in ipairs(stderr_output) do
        table.insert(display_lines, M.sanitize_line(line))
    end
    table.insert(display_lines, "```")
end

-- =============================================================================
-- Command Building
-- =============================================================================

--- Build the cursor-agent command array.
---@param opts table { prompt: string, model?: string, mode?: string, resume_id?: string }
---@return table cmd
function M.build_cursor_cmd(opts)
    local user_config = config.state.user_config
    local cmd = { "cursor-agent", "-p", "--output-format", "stream-json" }

    if user_config.stream_partial then
        table.insert(cmd, "--stream-partial-output")
    end

    -- Model
    local model = opts.model
    if model and model ~= "" then
        table.insert(cmd, "--model")
        table.insert(cmd, model)
    end

    -- Mode. "agent" is the CLI default and takes no flag. "quick" is a synthetic
    -- wrapper mode (context inlined into the prompt) and also runs flagless.
    local mode = opts.mode or "agent"
    if mode == "plan" or mode == "ask" then
        table.insert(cmd, "--mode")
        table.insert(cmd, mode)
    end

    -- Permission strategy
    if user_config.force then
        table.insert(cmd, "--force")
    elseif user_config.auto_review then
        table.insert(cmd, "--auto-review")
    end

    -- Continuation
    if opts.resume_id and opts.resume_id ~= "" then
        table.insert(cmd, "--resume")
        table.insert(cmd, opts.resume_id)
    end

    -- Prompt as the trailing positional argument
    if opts.prompt and vim.trim(opts.prompt) ~= "" then
        table.insert(cmd, vim.trim(opts.prompt))
    end

    return cmd
end

--- Build a shell-escaped display string for a command array
---@param cmd table
---@return string
function M.cmd_display(cmd)
    local parts = {}
    for _, part in ipairs(cmd) do
        table.insert(parts, vim.fn.shellescape(part))
    end
    return (table.concat(parts, " "):gsub("\n", "\\n"))
end

return M
