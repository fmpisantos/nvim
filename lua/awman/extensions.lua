local api = vim.api

function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function OpenFloatingWindow(content)
    local screen_width = vim.o.columns
    local screen_height = vim.o.lines

    local num_lines = #content
    local max_line_length = 0
    for _, line in ipairs(content) do
        if #line > max_line_length then
            max_line_length = #line
        end
    end

    local min_width = 20
    local min_height = 5
    local max_width = math.floor(screen_width * 0.9)
    local max_height = math.floor(screen_height * 0.9)

    local win_width = math.max(min_width, math.min(max_width, max_line_length + 4))
    local win_height = math.max(min_height, math.min(max_height, num_lines + 2))

    local win_row = math.floor((screen_height - win_height) / 2)
    local win_col = math.floor((screen_width - win_width) / 2)

    local buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_lines(buf, 0, -1, false, content)

    local win = api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = win_row,
        col = win_col,
        style = 'minimal',
        border = 'single',
    })

    api.nvim_win_set_option(win, 'wrap', false)
    api.nvim_win_set_option(win, 'cursorline', false)
    api.nvim_win_set_option(win, 'number', false)

    api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>lua vim.api.nvim_win_close(' .. win .. ', true)<cr>',
        { noremap = true, silent = true })
end

function show_current_line_popup()
    local current_line = api.nvim_get_current_line()
    current_line = trim(current_line)

    OpenFloatingWindow({ current_line })

    -- local bufnr = api.nvim_create_buf(false, true)
    -- api.nvim_buf_set_option(bufnr, 'textwidth', 60)
    --
    -- api.nvim_buf_set_lines(bufnr, 0, -1, true, { current_line })
    --
    -- local total_width = api.nvim_get_option("columns")
    -- local win_width = math.min(#current_line, math.max(math.floor(total_width * 0.7), 60))
    -- local win_height = math.ceil(#current_line / win_width)
    -- local row = math.floor(api.nvim_get_option("lines") / 2) - math.floor(win_height / 2)
    -- local col = math.floor(api.nvim_get_option("columns") / 2) - math.floor(win_width / 2)
    --
    -- local opts = {
    --     style = "minimal",
    --     focusable = false,
    --     relative = "editor",
    --     width = win_width,
    --     height = win_height,
    --     row = row,
    --     col = col,
    -- }
    --
    -- local win_id = api.nvim_open_win(bufnr, true, opts)
    --
    -- api.nvim_win_set_option(win_id, 'wrap', true)
    -- api.nvim_win_set_option(win_id, 'linebreak', true)
    --
    -- api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>lua vim.api.nvim_win_close(' .. win_id .. ', true)<cr>',
    --     { noremap = true, silent = true })
end

api.nvim_set_keymap("n", "<leader>l", ":lua show_current_line_popup()<cr>",
    { noremap = true, silent = true, desc = "show current line in popup" });
api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>tt', '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>dq',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>dt',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true })

function Exit_visual_and_wait_for_marks()
    vim.cmd('normal! <Esc>')
    vim.cmd('undo')

    vim.cmd('redraw')
    vim.defer_fn(function()
        if vim.fn.line('v') ~= 0 then
            return ""
        else
            Exit_visual_and_wait_for_marks()
        end
    end, 100)
end

function GetSelectedText()
    local mode = vim.api.nvim_get_mode().mode
    Exit_visual_and_wait_for_marks()

    local start_pos = vim.api.nvim_buf_get_mark(0, '<')
    local end_pos = vim.api.nvim_buf_get_mark(0, '>')

    if start_pos[1] == end_pos[1] and start_pos[2] == end_pos[2] then
        return ""
    end

    local buf = 0
    local lines = {}

    if mode == 'V' then
        if start_pos[1] == end_pos[1] then
            local line = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)[1]
            lines = { line }
        else
            lines = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)
        end
    elseif mode == 'v' then
        for i = start_pos[1], end_pos[1] do
            local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
            if i == start_pos[1] then
                line = line:sub(start_pos[2] + 1)
            end
            if i == end_pos[1] then
                line = line:sub(1, end_pos[2])
            end
            table.insert(lines, line)
        end
    elseif mode == '<C-v>' then
        return ""
    end
    return table.concat(lines, "\n")
end

vim.api.nvim_set_keymap("v", "<leader>vl", "<cmd>lua GetSelectedText()<cr>", { noremap = true })
