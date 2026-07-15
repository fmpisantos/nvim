local M = {}

-- =============================================================================
-- Runner Module
-- =============================================================================
-- Executes `cursor-agent -p --output-format stream-json`, streams the events
-- into the response buffer with a live status line, tracks the session id for
-- continuation, and supports queueing + cancellation of requests.

local config = require("cursor_agent.config")
local utils = require("cursor_agent.utils")
local ui = require("cursor_agent.ui")
local session = require("cursor_agent.session")
local response = require("cursor_agent.response")

-- =============================================================================
-- Request / Queue tracking
-- =============================================================================

M.is_busy = false
M.queue = {}
M.queue_suspended = false

--- Register an active request for cancellation tracking
---@param system_obj table vim.system object (needs :kill)
---@param cleanup_fn? function
---@return number request_id
local function register_request(system_obj, cleanup_fn)
    config.state.next_request_id = config.state.next_request_id + 1
    config.state.active_requests[config.state.next_request_id] = {
        system_obj = system_obj,
        cleanup_fn = cleanup_fn,
    }
    return config.state.next_request_id
end

--- Unregister a completed request
---@param request_id number
local function unregister_request(request_id)
    config.state.active_requests[request_id] = nil
end

--- Set the busy flag and drain the queue when idle
---@param busy boolean
local function set_busy(busy)
    M.is_busy = busy
    if not busy and not M.queue_suspended and #M.queue > 0 then
        local next_req = table.remove(M.queue, 1)
        M.is_busy = true
        vim.schedule(function()
            M.run(next_req.prompt, next_req.opts)
        end)
    end
end

--- Cancel all active requests and clear the queue
---@return number count
function M.cancel_all()
    local count = 0
    M.queue_suspended = true
    for id, req in pairs(config.state.active_requests) do
        if req.system_obj then
            pcall(function() req.system_obj:kill(9) end)
        end
        if req.cleanup_fn then
            pcall(req.cleanup_fn)
        end
        config.state.active_requests[id] = nil
        count = count + 1
    end
    M.queue = {}
    M.queue_suspended = false
    set_busy(false)
    return count
end

--- Number of active requests
---@return number
function M.get_active_request_count()
    local count = 0
    for _ in pairs(config.state.active_requests) do
        count = count + 1
    end
    return count
end

-- =============================================================================
-- Runner
-- =============================================================================

--- Run cursor-agent with the given prompt.
---@param prompt string
---@param opts? table { source_file?: string }
function M.run(prompt, opts)
    opts = opts or {}
    if not prompt or vim.trim(prompt) == "" then
        return
    end

    -- Queue if a request is already streaming.
    if M.is_busy then
        table.insert(M.queue, { prompt = prompt, opts = opts })
        vim.notify(
            string.format("Request queued (position %d). Will run when the current one finishes.", #M.queue),
            vim.log.levels.INFO
        )
        return
    end
    set_busy(true)

    local state = config.state

    -- Extract explicit session reference and mode keywords.
    local resume_id
    prompt, resume_id = utils.extract_session_from_prompt(prompt)
    resume_id = resume_id or state.current_session_id

    local remaining, mode_override = utils.parse_mode_keywords(prompt)
    prompt = remaining
    local mode = mode_override or config.get_mode()
    if mode_override then
        config.set_mode(mode_override)
    end

    local is_continuation = resume_id ~= nil
    if resume_id then
        state.current_session_id = resume_id
    end

    -- Preserve existing transcript when continuing.
    local existing_content = {}
    if is_continuation and state.response_buf and vim.api.nvim_buf_is_valid(state.response_buf) then
        existing_content = vim.api.nvim_buf_get_lines(state.response_buf, 0, -1, false)
    end

    local buf, _ = ui.create_response_split("CursorAgent Response", not is_continuation)
    vim.b[buf].cursor_agent_session_id = state.current_session_id

    local model = state.selected_model

    -- In quick mode, inline referenced file contents into the prompt sent to the
    -- CLI so the agent can answer without exploring the project. The displayed
    -- header keeps the original prompt to stay readable.
    local cli_prompt = prompt
    local quick_inlined = nil
    if mode == "quick" then
        cli_prompt, quick_inlined = utils.build_quick_prompt(prompt)
    end

    local cmd = utils.build_cursor_cmd({
        prompt = cli_prompt,
        model = model,
        mode = mode,
        resume_id = resume_id,
    })

    -- Command shown in the header uses the original (short) prompt.
    local display_cmd = cmd
    if mode == "quick" then
        display_cmd = utils.build_cursor_cmd({
            prompt = prompt,
            model = model,
            mode = mode,
            resume_id = resume_id,
        })
    end

    -- Build the static header for this query.
    local header_lines = {
        "**Mode:** [" .. mode .. "]  **Model:** " .. config.get_model_display(),
        "**Command:** `" .. utils.cmd_display(display_cmd) .. "`",
        "",
        "**Query:**",
    }
    vim.list_extend(header_lines, vim.split(prompt, "\n", { plain = true }))
    if quick_inlined ~= nil then
        table.insert(header_lines, "")
        table.insert(header_lines, "**Quick mode:** inlined " .. quick_inlined ..
            " referenced file(s); project exploration discouraged")
    end
    vim.list_extend(header_lines, { "", "---", "" })

    local display_prefix = {}
    if is_continuation and #existing_content > 0 then
        display_prefix = vim.deepcopy(existing_content)
        vim.list_extend(display_prefix, vim.split(config.SESSION_SEPARATOR, "\n", { plain = true }))
    end

    local full_header = vim.deepcopy(display_prefix)
    vim.list_extend(full_header, header_lines)

    -- Streaming state.
    local json_lines = {}
    local stderr_output = {}
    local stdout_partial = ""
    local stderr_partial = ""
    local system_obj = nil
    local is_running = true
    local run_start_time = vim.loop.now()
    local spinner_idx = 1
    local update_timer = nil
    local request_id = nil

    local function stop_timer()
        if update_timer then
            vim.fn.timer_stop(update_timer)
            update_timer = nil
        end
    end

    local function render(final)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        local parsed = response.parse(json_lines)

        -- Capture the session id as soon as cursor-agent reports it.
        if parsed.session_id and state.current_session_id ~= parsed.session_id then
            state.current_session_id = parsed.session_id
            vim.b[buf].cursor_agent_session_id = parsed.session_id
        end

        local display_lines = vim.deepcopy(full_header)

        if is_running and not final then
            local spinner_char = config.SPINNER_FRAMES[spinner_idx]
            spinner_idx = (spinner_idx % #config.SPINNER_FRAMES) + 1

            local seconds = math.floor((vim.loop.now() - run_start_time) / 1000)
            local elapsed = " (" .. seconds .. "s)"
            local status_text
            if parsed.is_thinking then
                status_text = "**Status:** Thinking" .. elapsed .. " " .. spinner_char
            elseif parsed.current_tool then
                local verb = (parsed.tool_status == "completed") and "Completed" or "Executing"
                status_text = "**Status:** " .. verb .. " `" ..
                    utils.sanitize_line(parsed.current_tool) .. "`" .. elapsed .. " " .. spinner_char
            else
                status_text = "**Status:** Running" .. elapsed .. " " .. spinner_char
            end
            table.insert(display_lines, status_text)
            table.insert(display_lines, "")
        end

        if parsed.error_message then
            table.insert(display_lines, "**Error:** " .. utils.sanitize_line(parsed.error_message))
            utils.append_stderr_block(display_lines, stderr_output)
        elseif #parsed.response_lines > 0 then
            vim.list_extend(display_lines, parsed.response_lines)
        elseif final then
            table.insert(display_lines, "No response received.")
            utils.append_stderr_block(display_lines, stderr_output)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)

        local wins = vim.fn.win_findbuf(buf)
        if #wins > 0 then
            local line_count = vim.api.nvim_buf_line_count(buf)
            pcall(vim.api.nvim_win_set_cursor, wins[1], { line_count, 0 })
        end
    end

    local function start_update_timer()
        update_timer = vim.fn.timer_start(config.SPINNER_INTERVAL_MS, function()
            vim.schedule(function()
                if is_running then
                    render(false)
                    start_update_timer()
                end
            end)
        end)
    end

    local function finalize()
        is_running = false
        stop_timer()
        if request_id then
            unregister_request(request_id)
            request_id = nil
        end
        set_busy(false)
        render(true)
    end

    -- Optional hard timeout.
    if state.user_config.timeout_ms and state.user_config.timeout_ms ~= -1 then
        vim.fn.timer_start(state.user_config.timeout_ms, function()
            if is_running then
                vim.schedule(function()
                    if not is_running then return end
                    is_running = false
                    stop_timer()
                    if system_obj then
                        pcall(function() system_obj:kill(9) end)
                    end
                    if request_id then
                        unregister_request(request_id)
                        request_id = nil
                    end
                    set_busy(false)
                    if vim.api.nvim_buf_is_valid(buf) then
                        local lines = vim.deepcopy(full_header)
                        table.insert(lines, "**Error:** Request timed out after " ..
                            math.floor(state.user_config.timeout_ms / 1000) .. " seconds")
                        utils.append_stderr_block(lines, stderr_output)
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                    end
                end)
            end
        end)
    end

    local function consume_stream(partial_ref, data, sink)
        local combined = partial_ref .. data
        local last_nl = combined:find("[\r\n][^\r\n]*$")
        local complete, tail
        if last_nl then
            complete = combined:sub(1, last_nl)
            tail = combined:sub(last_nl + 1)
        else
            complete = ""
            tail = combined
        end
        for line in complete:gmatch("[^\r\n]+") do
            table.insert(sink, line)
        end
        return tail
    end

    render(false)
    start_update_timer()

    system_obj = vim.system(cmd, {
        cwd = config.get_cwd(),
        stdout = function(_, data)
            if data then
                vim.schedule(function()
                    stdout_partial = consume_stream(stdout_partial, data, json_lines)
                    render(false)
                end)
            end
        end,
        stderr = function(_, data)
            if data then
                vim.schedule(function()
                    stderr_partial = consume_stream(stderr_partial, data, stderr_output)
                end)
            end
        end,
    }, function(result)
        vim.schedule(function()
            if stdout_partial ~= "" then
                table.insert(json_lines, stdout_partial)
                stdout_partial = ""
            end
            if stderr_partial ~= "" then
                table.insert(stderr_output, stderr_partial)
                stderr_partial = ""
            end

            -- Surface a non-zero exit when there's no parsed response.
            local parsed = response.parse(json_lines)
            if result.code ~= 0 and not parsed.error_message and #parsed.response_lines == 0 then
                table.insert(stderr_output, "cursor-agent exited with code " .. tostring(result.code))
            end

            finalize()
        end)
    end)

    local cleanup_fn = function()
        is_running = false
        stop_timer()
        set_busy(false)
    end
    request_id = register_request(system_obj, cleanup_fn)

    vim.api.nvim_create_autocmd("BufDelete", {
        buffer = buf,
        once = true,
        callback = function()
            if system_obj and is_running then
                pcall(function() system_obj:kill(9) end)
            end
            stop_timer()
            if request_id then
                unregister_request(request_id)
            end
        end,
    })
end

return M
