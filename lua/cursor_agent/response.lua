local M = {}

-- =============================================================================
-- Response Module
-- =============================================================================
-- Parses cursor-agent `--output-format stream-json` events.
--
-- Event shapes (one JSON object per line):
--   {"type":"system","subtype":"init","session_id":"..","model":"..","permissionMode":".."}
--   {"type":"user","message":{...}}
--   {"type":"thinking","subtype":"delta"|"completed","text":".."}
--   {"type":"tool_call","subtype":"started"|"completed","tool_call":{ <name>ToolCall = {..}, description = ".." }}
--   {"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":".."}]},"timestamp_ms":..?}
--   {"type":"result","subtype":"success"|"error","is_error":bool,"result":"..","session_id":".."}
--
-- With --stream-partial-output, assistant text arrives as many delta events
-- (each carrying `timestamp_ms`) followed by a single consolidated message
-- (no `timestamp_ms`). Without it, only the consolidated message(s) arrive.

--- Extract the concatenated text from an assistant message.content array
---@param message table
---@return string
local function extract_message_text(message)
    if not message or type(message.content) ~= "table" then
        return ""
    end
    local parts = {}
    for _, item in ipairs(message.content) do
        if type(item) == "table" and item.type == "text" and item.text then
            table.insert(parts, item.text)
        end
    end
    return table.concat(parts, "")
end

--- Derive a human-readable tool name from a tool_call payload
---@param tool_call table
---@return string
local function extract_tool_name(tool_call)
    if type(tool_call) ~= "table" then
        return "tool"
    end
    -- Prefer an explicit description if present.
    if type(tool_call.description) == "string" and tool_call.description ~= "" then
        return tool_call.description
    end
    -- Otherwise use the "<name>ToolCall" key.
    for k, _ in pairs(tool_call) do
        local name = k:match("^(.-)ToolCall$")
        if name then
            return name
        end
    end
    return "tool"
end

--- Parse the accumulated stream-json lines into a display state.
---@param json_lines table Lines of JSON received so far
---@return table state {
---   response_lines: string[],
---   error_message: string|nil,
---   is_thinking: boolean,
---   current_tool: string|nil,
---   tool_status: string|nil,
---   session_id: string|nil,
---   model: string|nil,
---   done: boolean,
---   result_text: string|nil,
--- }
function M.parse(json_lines)
    local state = {
        response_lines = {},
        error_message = nil,
        is_thinking = false,
        current_tool = nil,
        tool_status = nil,
        session_id = nil,
        model = nil,
        done = false,
        result_text = nil,
    }

    local response_text = ""
    local seen_delta = false

    for _, line in ipairs(json_lines) do
        if line and line ~= "" then
            local ok, data = pcall(vim.json.decode, line)
            if ok and type(data) == "table" then
                if data.session_id and not state.session_id then
                    state.session_id = data.session_id
                end

                local t = data.type

                if t == "system" then
                    if data.model then state.model = data.model end
                elseif t == "thinking" then
                    if data.subtype == "completed" then
                        state.is_thinking = false
                    else
                        state.is_thinking = true
                        state.current_tool = nil
                    end
                elseif t == "tool_call" then
                    state.is_thinking = false
                    state.current_tool = extract_tool_name(data.tool_call)
                    state.tool_status = (data.subtype == "completed") and "completed" or "running"
                elseif t == "assistant" then
                    state.is_thinking = false
                    state.current_tool = nil
                    local text = extract_message_text(data.message)
                    if data.timestamp_ms ~= nil then
                        -- Delta chunk (partial streaming) — accumulate.
                        response_text = response_text .. text
                        seen_delta = true
                    else
                        -- Consolidated message. In partial mode it duplicates the
                        -- accumulated deltas, so ignore it there; otherwise append.
                        if not seen_delta then
                            response_text = response_text .. text
                        end
                    end
                elseif t == "result" then
                    state.done = true
                    if data.is_error or data.subtype == "error" then
                        state.error_message = data.error
                            or (type(data.result) == "string" and data.result)
                            or "cursor-agent reported an error"
                    end
                    if type(data.result) == "string" and data.result ~= "" then
                        state.result_text = data.result
                    end
                elseif t == "error" then
                    state.error_message = data.error
                        or data.message
                        or "Unknown error"
                end
            end
        end
    end

    -- Prefer the authoritative final result text if we have it.
    local final_text = state.result_text
    if not final_text or final_text == "" then
        final_text = response_text
    end

    if final_text and final_text ~= "" then
        local normalized = final_text:gsub("\r\n", "\n"):gsub("\r", "\n")
        state.response_lines = vim.split(normalized, "\n", { plain = true })
    end

    return state
end

return M
