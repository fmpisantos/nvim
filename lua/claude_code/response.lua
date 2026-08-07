local M = {}

-- =============================================================================
-- Response Module
-- =============================================================================
-- Parses `claude -p --output-format stream-json --verbose` events.
--
-- Event shapes (one JSON object per line):
--   {"type":"system","subtype":"init","session_id":"..","model":"..","tools":[..],"permissionMode":".."}
--   {"type":"assistant","message":{"role":"assistant","content":[{"type":"text"|"thinking"|"tool_use",..}]},..}
--   {"type":"user","message":{"role":"user","content":[{"type":"tool_result",..}]},..}
--   {"type":"result","subtype":"success","is_error":false,"result":"..","total_cost_usd":..,"duration_ms":..}
--
-- With --include-partial-messages the stream also carries live previews:
--   {"type":"stream_event","event":{"type":"content_block_start","content_block":{"type":"text"|"thinking"|"tool_use",..}}}
--   {"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"text_delta","text":".."}}}
--
-- Reconciliation: deltas accumulate into `pending`, which is rendered as a live
-- tail. When the consolidated `assistant` message for that block arrives, its
-- text becomes authoritative and `pending` is discarded. Deltas are best-effort
-- and may be shed under load, so the buffered message always wins.

--- Extract text and inspect blocks of an assistant message.
---@param message table
---@return string text Concatenated text blocks ("" when the message has none)
---@return boolean has_text
---@return boolean has_thinking
---@return string|nil tool_name Name of the last tool_use block, if any
local function inspect_assistant_message(message)
    if not message or type(message.content) ~= "table" then
        return "", false, false, nil
    end
    local parts = {}
    local has_thinking = false
    local tool_name = nil
    for _, item in ipairs(message.content) do
        if type(item) == "table" then
            if item.type == "text" and item.text then
                table.insert(parts, item.text)
            elseif item.type == "thinking" then
                has_thinking = true
            elseif item.type == "tool_use" then
                tool_name = item.name or "tool"
            end
        end
    end
    return table.concat(parts, ""), #parts > 0, has_thinking, tool_name
end

--- Does a user message carry a tool_result block?
---@param message table
---@return boolean
local function has_tool_result(message)
    if not message or type(message.content) ~= "table" then
        return false
    end
    for _, item in ipairs(message.content) do
        if type(item) == "table" and item.type == "tool_result" then
            return true
        end
    end
    return false
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
---   cost_usd: number|nil,
---   duration_ms: number|nil,
---   num_turns: number|nil,
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
        cost_usd = nil,
        duration_ms = nil,
        num_turns = nil,
    }

    -- Text from consolidated assistant messages (authoritative), one entry per
    -- message so separate messages in a turn stay visually separated.
    local finalized = {}
    -- Live text accumulated from deltas since the last consolidated message.
    local pending = ""

    for _, line in ipairs(json_lines) do
        if line and line ~= "" then
            local ok, data = pcall(vim.json.decode, line)
            if ok and type(data) == "table" then
                if data.session_id and not state.session_id then
                    state.session_id = data.session_id
                end

                local t = data.type

                if t == "system" then
                    if data.subtype == "init" and data.model then
                        state.model = data.model
                    end
                elseif t == "stream_event" then
                    local event = data.event
                    if type(event) == "table" then
                        if event.type == "content_block_start" then
                            local block = event.content_block
                            if type(block) == "table" then
                                if block.type == "thinking" then
                                    state.is_thinking = true
                                    state.current_tool = nil
                                elseif block.type == "tool_use" then
                                    state.is_thinking = false
                                    state.current_tool = block.name or "tool"
                                    state.tool_status = "running"
                                elseif block.type == "text" then
                                    state.is_thinking = false
                                end
                            end
                        elseif event.type == "content_block_delta" then
                            local delta = event.delta
                            if type(delta) == "table" then
                                if delta.type == "text_delta" and delta.text then
                                    state.is_thinking = false
                                    state.current_tool = nil
                                    pending = pending .. delta.text
                                elseif delta.type == "thinking_delta" then
                                    state.is_thinking = true
                                end
                            end
                        end
                    end
                elseif t == "assistant" then
                    local text, has_text, has_thinking, tool_name =
                        inspect_assistant_message(data.message)
                    if has_text then
                        table.insert(finalized, text)
                        -- The buffered message supersedes its streamed preview.
                        pending = ""
                        state.is_thinking = false
                        state.current_tool = nil
                    end
                    if tool_name then
                        state.is_thinking = false
                        state.current_tool = tool_name
                        state.tool_status = "running"
                    elseif has_thinking and not has_text then
                        state.is_thinking = true
                    end
                elseif t == "user" then
                    if has_tool_result(data.message) then
                        state.tool_status = "completed"
                    end
                elseif t == "result" then
                    state.done = true
                    state.is_thinking = false
                    state.current_tool = nil
                    state.cost_usd = data.total_cost_usd
                    state.duration_ms = data.duration_ms
                    state.num_turns = data.num_turns
                    if data.is_error or (data.subtype and data.subtype ~= "success") then
                        state.error_message = (type(data.result) == "string" and data.result)
                            or data.error
                            or ("claude reported an error (" .. tostring(data.subtype) .. ")")
                    end
                    if type(data.result) == "string" and data.result ~= "" then
                        state.result_text = data.result
                    end
                elseif t == "error" then
                    state.error_message = data.error or data.message or "Unknown error"
                end
            end
        end
    end

    local final_text = table.concat(finalized, "\n\n")
    if pending ~= "" then
        if final_text ~= "" then
            final_text = final_text .. "\n\n" .. pending
        else
            final_text = pending
        end
    end
    -- Nothing streamed through (e.g. deltas disabled and the run errored early):
    -- fall back to the authoritative final result text.
    if final_text == "" and state.result_text then
        final_text = state.result_text
    end

    if final_text ~= "" then
        local normalized = final_text:gsub("\r\n", "\n"):gsub("\r", "\n")
        state.response_lines = vim.split(normalized, "\n", { plain = true })
    end

    return state
end

return M
