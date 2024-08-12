local api = vim.api

function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function show_current_line_popup()
    local current_line = api.nvim_get_current_line()
    current_line = trim(current_line)

    local bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(bufnr, 'textwidth', 60)

    api.nvim_buf_set_lines(bufnr, 0, -1, true, { current_line })

    local total_width = api.nvim_get_option("columns")
    local win_width = math.min(#current_line, math.max(math.floor(total_width * 0.7), 60))
    local win_height = math.ceil(#current_line / win_width)
    local row = math.floor(api.nvim_get_option("lines") / 2) - math.floor(win_height / 2)
    local col = math.floor(api.nvim_get_option("columns") / 2) - math.floor(win_width / 2)

    local opts = {
        style = "minimal",
        focusable = false,
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }

    local win_id = api.nvim_open_win(bufnr, true, opts)

    api.nvim_win_set_option(win_id, 'wrap', true)
    api.nvim_win_set_option(win_id, 'linebreak', true)

    api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>lua vim.api.nvim_win_close(' .. win_id .. ', true)<cr>',
        { noremap = true, silent = true })
end

api.nvim_set_keymap("n", "<leader>l", ":lua show_current_line_popup()<cr>",
    { noremap = true, silent = true, desc = "show current line in popup" });
api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>tt', '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>dq',
    '<cmd>lua diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true })
api.nvim_set_keymap('n', '<leader>dt',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true })
