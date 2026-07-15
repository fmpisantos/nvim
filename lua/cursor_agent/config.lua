local M = {}

-- =============================================================================
-- Configuration Module
-- =============================================================================
-- Centralized configuration and state management for cursor_agent.
-- Persists model/mode selection via shared_buffer.nvim when available,
-- falling back to a plain JSON file otherwise.

-- =============================================================================
-- Constants
-- =============================================================================

M.SPINNER_FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
M.SPINNER_INTERVAL_MS = 80
M.SESSION_SEPARATOR = "\n\n===============================================================================\n\n"
M.NEW_SESSION_LABEL = "(New Chat)"

-- Valid execution modes for cursor-agent
--   agent : full read/write/shell tools (default)
--   plan  : read-only planning (--mode plan)
--   ask   : read-only Q&A (--mode ask)
--   quick : synthetic mode. Inlines the contents of @-referenced files into the
--           prompt and instructs the agent to rely only on those files (no
--           project exploration). Runs the CLI without a --mode flag; the
--           restriction is enforced by instruction, not sandboxing.
M.MODES = { "agent", "plan", "ask", "quick" }

-- Instruction prepended to prompts in "quick" mode. cursor-agent is always
-- agentic (it can read/grep/search the whole project), so we cannot hard-fence
-- it to referenced files only. This preamble asks it to behave like a
-- context-limited "quick" chat that uses solely the provided file contents.
M.QUICK_MODE_PREAMBLE = table.concat({
    "You are operating in QUICK mode.",
    "Only use the file contents provided below in \"Referenced file contents\" to answer.",
    "Do NOT read, open, search, grep, list, or otherwise explore any other files in the project.",
    "If the provided files are insufficient to answer, say so explicitly instead of exploring.",
}, "\n")

-- =============================================================================
-- Default Configuration
-- =============================================================================

M.defaults = {
    prompt_window = {
        width = 60,
        height = 10,
    },
    response_buffer = {
        wrap = true,
    },
    -- Timeout in milliseconds. Set to -1 to disable (recommended for agents
    -- that may run long shell commands or many tool calls).
    timeout_ms = -1,
    keymaps = {
        enable_default = true,
        open_prompt = "<leader>ca",
    },
    -- Default execution mode ("agent", "plan" or "ask")
    mode = "agent",
    -- Permission handling for tool calls. cursor-agent runs headless (-p) and
    -- cannot prompt interactively, so one of these strategies is used:
    --   force       : pass --force (run every tool call, incl. writes/shell)
    --   auto_review : pass --auto-review (server classifier auto-runs safe calls)
    -- If both are false, cursor-agent's default headless behaviour is used.
    force = true,
    auto_review = false,
    -- Stream partial assistant output as individual text deltas for smoother UI.
    stream_partial = true,
}

-- =============================================================================
-- Persistence (shared_buffer with file fallback)
-- =============================================================================

local shared_buffer_ok, shared_buffer = pcall(require, "shared_buffer")

local config_state, save_config_state

if shared_buffer_ok then
    config_state, save_config_state = shared_buffer.setup("cursor_agent_config")
else
    local config_file = vim.fn.stdpath("data") .. "/cursor_agent/config.json"

    config_state = { bufnr = -1 }
    if vim.fn.filereadable(config_file) == 1 then
        local content = vim.fn.readfile(config_file)
        if #content > 0 then
            local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
            if ok and data then
                config_state = data
            end
        end
    end

    save_config_state = function(state)
        vim.fn.mkdir(vim.fn.fnamemodify(config_file, ":h"), "p")
        vim.fn.writefile({ vim.json.encode(state) }, config_file)
    end
end

-- =============================================================================
-- State (mutable)
-- =============================================================================

---@class CursorAgentState
---@field selected_model string|nil
---@field mode string|nil
---@field draft_content table|nil
---@field draft_cursor table|nil
---@field user_config table
---@field is_initialized boolean
---@field current_session_id string|nil
---@field current_session_name string|nil
---@field response_buf number|nil
---@field response_win number|nil
---@field prompt_buf number|nil
---@field prompt_win number|nil
---@field active_requests table
---@field next_request_id number

M.state = {
    selected_model = config_state.model,
    mode = config_state.mode,

    draft_content = nil,
    draft_cursor = nil,
    user_config = vim.deepcopy(M.defaults),
    is_initialized = false,

    current_session_id = nil,
    current_session_name = nil,
    response_buf = nil,
    response_win = nil,

    prompt_buf = nil,
    prompt_win = nil,

    active_requests = {},
    next_request_id = 0,
}

-- =============================================================================
-- Persistence helpers
-- =============================================================================

--- Save configuration (model, mode) to disk
function M.save_config()
    config_state.model = M.state.selected_model
    config_state.mode = M.state.mode
    save_config_state(config_state)
end

-- =============================================================================
-- Accessors
-- =============================================================================

--- Get current working directory (evaluated at call time)
---@return string
function M.get_cwd()
    return vim.fn.getcwd()
end

--- Get model display name (falls back to "auto")
---@return string
function M.get_model_display()
    if M.state.selected_model and M.state.selected_model ~= "" then
        return M.state.selected_model
    end
    return "auto"
end

--- Get the current execution mode
---@return string mode "agent" | "plan" | "ask" | "quick"
function M.get_mode()
    if M.state.mode then
        return M.state.mode
    end
    return M.state.user_config.mode or "agent"
end

--- Set the execution mode
---@param mode string "agent" | "plan" | "ask" | "quick"
---@return boolean success
function M.set_mode(mode)
    if not vim.tbl_contains(M.MODES, mode) then
        vim.notify("Invalid mode: " .. tostring(mode) .. ". Use 'agent', 'plan', 'ask' or 'quick'.",
            vim.log.levels.ERROR)
        return false
    end
    M.state.mode = mode
    return true
end

--- Get session display name for titles
---@return string
function M.get_session_display()
    if M.state.current_session_name then
        local display = M.state.current_session_name:sub(1, 20)
        if #M.state.current_session_name > 20 then
            display = display .. "..."
        end
        return display
    elseif M.state.current_session_id then
        return "Chat: " .. M.state.current_session_id:sub(1, 8)
    end
    return "New"
end

-- =============================================================================
-- Setup
-- =============================================================================

--- Initialize configuration (called once at setup)
---@param opts? table User configuration options
function M.setup(opts)
    if opts then
        M.state.user_config = vim.tbl_deep_extend("force", M.defaults, opts)
    end
    -- Seed mode from persisted state or config default
    if not M.state.mode then
        M.state.mode = M.state.user_config.mode
    end
end

return M
