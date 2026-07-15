local M = {}

-- =============================================================================
-- cursor_agent - Main Module
-- =============================================================================
-- A Neovim integration for the `cursor-agent` CLI, mirroring the opencode.nvim
-- workflow: a floating prompt window, a streaming response buffer, model and
-- mode selection, and session (chat) continuation.

local config = require("cursor_agent.config")
local utils = require("cursor_agent.utils")
local ui = require("cursor_agent.ui")
local sessionmod = require("cursor_agent.session")
local runner = require("cursor_agent.runner")

local select_session_for_prompt

-- =============================================================================
-- Prompt Window
-- =============================================================================

--- Open the main prompt window
---@param initial_prompt? table Initial prompt lines (from a visual selection)
---@param filetype? string Filetype for the code fence
---@param source_file? string Source file path
---@param session_id_to_continue? string Session id to continue
function M.Open(initial_prompt, filetype, source_file, session_id_to_continue)
    local state = config.state

    local from_response_session = sessionmod.get_session_from_current_buffer()
    local session_to_use = session_id_to_continue or from_response_session

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

    sessionmod.clear_session()

    -- Recover an existing prompt buffer if module state was lost.
    if not state.prompt_buf or not vim.api.nvim_buf_is_valid(state.prompt_buf) then
        local existing = vim.fn.bufnr("cursoragent://prompt")
        if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
            state.prompt_buf = existing
        end
    end

    local reuse_existing_buffer = false
    if state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf) then
        local wins = vim.fn.win_findbuf(state.prompt_buf)
        for _, w in ipairs(wins) do
            local win_config = vim.api.nvim_win_get_config(w)
            if win_config.relative == "" then
                vim.api.nvim_win_close(w, false)
            end
        end
        if not initial_prompt then
            local lines = vim.api.nvim_buf_get_lines(state.prompt_buf, 0, -1, false)
            local has_content = vim.iter(lines):any(function(line) return line ~= "" end)
            if has_content then
                reuse_existing_buffer = true
            end
        end
    end

    local buf, win

    local function open_win(b)
        return vim.api.nvim_open_win(b, true, {
            relative = "editor",
            width = state.user_config.prompt_window.width,
            height = state.user_config.prompt_window.height,
            col = (vim.o.columns - state.user_config.prompt_window.width) / 2,
            row = (vim.o.lines - state.user_config.prompt_window.height) / 2,
            style = "minimal",
            border = "rounded",
            title = ui.get_window_title(nil, session_to_use),
            title_pos = "center",
        })
    end

    if reuse_existing_buffer and state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf) then
        buf = state.prompt_buf
        win = open_win(buf)
    else
        if state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf) then
            pcall(function() vim.bo[state.prompt_buf].bufhidden = "wipe" end)
            pcall(vim.api.nvim_buf_delete, state.prompt_buf, { force = true })
            state.prompt_buf = nil
        end
        local existing = vim.fn.bufnr("cursoragent://prompt")
        if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
            pcall(function() vim.bo[existing].bufhidden = "wipe" end)
            pcall(vim.api.nvim_buf_delete, existing, { force = true })
        end

        buf = vim.api.nvim_create_buf(false, true)
        win = open_win(buf)

        vim.bo[buf].buftype = "acwrite"
        vim.bo[buf].bufhidden = "hide"
        vim.bo[buf].filetype = "cursoragent"
        vim.bo[buf].swapfile = false
        vim.bo[buf].buflisted = false

        local name_buf = vim.fn.bufnr("cursoragent://prompt")
        if name_buf == -1 or not vim.api.nvim_buf_is_valid(name_buf) then
            vim.api.nvim_buf_set_name(buf, "cursoragent://prompt")
        else
            vim.api.nvim_buf_set_name(buf, "cursoragent://prompt-" .. buf)
        end
    end

    state.prompt_buf = buf
    state.prompt_win = win
    vim.b[buf].cursor_agent_source_file = source_file

    if not reuse_existing_buffer then
        if initial_prompt then
            state.draft_content = nil
            state.draft_cursor = nil
            local initial_lines = {}
            if session_to_use then
                table.insert(initial_lines, "#session(" .. session_to_use .. ")")
            end
            if source_file and source_file ~= "" then
                table.insert(initial_lines, "#buffer")
            end
            table.insert(initial_lines, "```" .. (filetype or ""))
            vim.list_extend(initial_lines, initial_prompt)
            vim.list_extend(initial_lines, { "```", "" })
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_lines)
            vim.api.nvim_win_set_cursor(win, { #initial_lines, 0 })
        elseif state.draft_content then
            local lines_to_set = vim.deepcopy(state.draft_content)
            if session_to_use and not utils.has_session_reference(table.concat(lines_to_set, "\n")) then
                table.insert(lines_to_set, 1, "#session(" .. session_to_use .. ")")
            end
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines_to_set)
            if state.draft_cursor then
                local row_offset = (session_to_use and not utils.has_session_reference(table.concat(state.draft_content, "\n"))) and 1 or 0
                pcall(vim.api.nvim_win_set_cursor, win, { state.draft_cursor[1] + row_offset, state.draft_cursor[2] })
            end
        elseif session_to_use then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "#session(" .. session_to_use .. ")", "" })
            vim.api.nvim_win_set_cursor(win, { 2, 0 })
        end
    end

    vim.cmd("startinsert")

    local augroup_name = "CursorAgentPrompt_" .. buf
    vim.api.nvim_create_augroup(augroup_name, { clear = true })

    -- Update title and handle the bare #session trigger (session picker).
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = augroup_name,
        buffer = buf,
        callback = function()
            if not state.prompt_win or not vim.api.nvim_win_is_valid(state.prompt_win) then
                return
            end

            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local content = table.concat(lines, "\n")

            if (content:match("#session%s*$") or content:match("#session[%s\n]")) and not content:match("#session%(") then
                local new_lines = {}
                for _, line in ipairs(lines) do
                    local new_line = line:gsub("#session%s*$", ""):gsub("#session([%s\n])", "%1")
                    table.insert(new_lines, new_line)
                end
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)

                local cursor_pos = vim.api.nvim_win_get_cursor(state.prompt_win)
                state.draft_content = new_lines
                state.draft_cursor = cursor_pos
                vim.bo[buf].modified = false

                vim.api.nvim_win_close(state.prompt_win, false)
                state.prompt_win = nil
                select_session_for_prompt(source_file)
                return
            end

            local win_config = vim.api.nvim_win_get_config(state.prompt_win)
            if win_config.relative and win_config.relative ~= "" then
                local session_in_content = content:match("#session%(([^)]+)%)")
                vim.api.nvim_win_set_config(state.prompt_win, {
                    title = ui.get_window_title(content, session_in_content),
                    title_pos = "center",
                })
            end
        end,
    })

    local function submit_prompt()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local content = table.concat(lines, "\n")

        -- Resolve #buffer / #buf into an @path reference to the source file.
        if source_file and source_file ~= "" then
            content = content:gsub("#buffer", "@" .. source_file):gsub("#buf", "@" .. source_file)
        end

        content = content:gsub("#session%s*$", ""):gsub("#session([%s\n])", "%1")

        state.draft_content = nil
        state.draft_cursor = nil
        vim.bo[buf].modified = false

        local wins = vim.fn.win_findbuf(buf)
        for _, w in ipairs(wins) do
            if vim.api.nvim_win_is_valid(w) then
                vim.api.nvim_win_close(w, false)
            end
        end
        state.prompt_win = nil

        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
        end

        if content and vim.trim(content) ~= "" then
            runner.run(content, { source_file = source_file })
        end
    end

    local function save_draft_and_close()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local has_content = vim.iter(lines):any(function(line) return line ~= "" end)

        if has_content then
            state.draft_content = lines
            local current_win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_buf(current_win) == buf then
                state.draft_cursor = vim.api.nvim_win_get_cursor(current_win)
            end
        else
            state.draft_content = nil
            state.draft_cursor = nil
        end

        vim.bo[buf].modified = false
        local wins = vim.fn.win_findbuf(buf)
        for _, w in ipairs(wins) do
            if vim.api.nvim_win_is_valid(w) then
                vim.api.nvim_win_close(w, false)
            end
        end
        state.prompt_win = nil
    end

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = augroup_name,
        buffer = buf,
        callback = submit_prompt,
    })

    vim.cmd("cnoreabbrev <buffer> wq w")
    vim.cmd("cnoreabbrev <buffer> x w")

    vim.keymap.set("n", "q", save_draft_and_close, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("n", "<Esc>", save_draft_and_close, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("n", "<CR>", submit_prompt, { buffer = buf, noremap = true, silent = true, desc = "Submit prompt" })
end

-- =============================================================================
-- Model Selection
-- =============================================================================

function M.SelectModel()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local state = config.state

    local result = vim.system({ "cursor-agent", "models" }, { text = true }):wait()

    -- Each entry: { id = "gpt-5.3-codex", label = "gpt-5.3-codex - Codex 5.3" }
    local models = { { id = nil, label = "(auto - default)" } }
    if result.stdout then
        for line in result.stdout:gmatch("[^\r\n]+") do
            local id, desc = line:match("^%s*([%w%.%-%_%[%]=,]+)%s*%-%s*(.+)$")
            if id then
                models[#models + 1] = { id = id, label = id .. " - " .. desc }
            end
        end
    end

    pickers.new({}, {
        prompt_title = "Select CursorAgent Model",
        finder = finders.new_table({
            results = models,
            entry_maker = function(entry)
                return { value = entry, display = entry.label, ordinal = entry.label }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    state.selected_model = selection.value.id
                    config.save_config()
                    vim.notify("CursorAgent model set to: " .. config.get_model_display(), vim.log.levels.INFO)
                end
            end)
            return true
        end,
    }):find()
end

-- =============================================================================
-- Mode Selection
-- =============================================================================

--- Get the current mode
---@return string
function M.GetMode()
    return config.get_mode()
end

--- Set or cycle the execution mode
---@param mode? string "agent" | "plan" | "ask" (cycles when nil)
function M.SetMode(mode)
    if not mode then
        local current = config.get_mode()
        local order = config.MODES
        local idx = 1
        for i, m in ipairs(order) do
            if m == current then idx = i break end
        end
        mode = order[(idx % #order) + 1]
    end

    if config.set_mode(mode) then
        config.save_config()
        vim.notify("CursorAgent mode set to: " .. mode, vim.log.levels.INFO)
    end
end

-- =============================================================================
-- Session Selection
-- =============================================================================

--- Open the session picker
---@param callback? function callback(session_id, session_name)
local function open_session_picker(callback)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local state = config.state
    local sessions = sessionmod.list_sessions()

    local entries = { { id = nil, display = config.NEW_SESSION_LABEL, name = nil } }
    for _, sess in ipairs(sessions) do
        table.insert(entries, sess)
    end

    local session_previewer = previewers.new_buffer_previewer({
        title = "Chat Preview",
        define_preview = function(self, entry, _)
            local entry_val = entry.value
            local bufnr = self.state.bufnr
            if not entry_val or not entry_val.id then
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Start a new chat" })
                return
            end
            local content = sessionmod.load_session_preview(entry_val.id)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n", { plain = true }))
            vim.bo[bufnr].filetype = "markdown"
        end,
    })

    pickers.new({}, {
        prompt_title = "CursorAgent Chats",
        finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
                return { value = entry, display = entry.display, ordinal = entry.display }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = session_previewer,
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local entry = selection.value
                    if callback then
                        callback(entry.id, entry.name)
                    else
                        if entry.id then
                            state.current_session_id = entry.id
                            state.current_session_name = entry.name
                            local content = sessionmod.load_session_preview(entry.id)
                            local buf, _ = ui.create_response_split("CursorAgent Response", true)
                            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
                            vim.b[buf].cursor_agent_session_id = entry.id
                            vim.notify("Loaded chat: " .. (entry.name or entry.id), vim.log.levels.INFO)
                        else
                            sessionmod.start_new_session()
                            vim.notify("Started new chat", vim.log.levels.INFO)
                        end
                    end
                end
            end)
            return true
        end,
    }):find()
end

--- Session picker used by the #session trigger in the prompt window
select_session_for_prompt = function(source_file)
    open_session_picker(function(session_id, session_name)
        local state = config.state
        if session_id then
            state.current_session_id = session_id
            state.current_session_name = session_name
            M.Open(nil, nil, source_file, session_id)
        else
            M.Open(nil, nil, source_file, nil)
        end
    end)
end

function M.SelectSession()
    open_session_picker()
end

-- =============================================================================
-- Misc actions
-- =============================================================================

function M.ToggleCLI()
    ui.toggle_response_buffer()
end

function M.NewSession()
    sessionmod.start_new_session()
    vim.notify("Started new chat", vim.log.levels.INFO)
end

function M.StopAll()
    local count = runner.cancel_all()
    if count > 0 then
        vim.notify("Stopped " .. count .. " request(s)", vim.log.levels.INFO)
    else
        vim.notify("No active requests to stop", vim.log.levels.INFO)
    end
end

-- =============================================================================
-- Setup
-- =============================================================================

--- Setup the cursor_agent plugin
---@param opts? table User configuration options
function M.setup(opts)
    local state = config.state
    if state.is_initialized then
        return
    end

    config.setup(opts)

    local commands = require("cursor_agent.commands")
    commands.setup(M, state.user_config)
    ui.setup_auto_reload()

    vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
            if state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf) then
                vim.bo[state.prompt_buf].modified = false
            end
            local prompt_buf = vim.fn.bufnr("cursoragent://prompt")
            if prompt_buf ~= -1 and vim.api.nvim_buf_is_valid(prompt_buf) then
                vim.bo[prompt_buf].modified = false
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            runner.cancel_all()
        end,
    })

    state.is_initialized = true
end

return M
