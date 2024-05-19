local api = vim.api

function show_current_line_popup()
    local current_line = api.nvim_get_current_line()
    local bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(bufnr, 'textwidth', 60) -- Set textwidth for wrapping

    api.nvim_buf_set_lines(bufnr, 0, -1, true, { current_line })

    local win_width = 60
    local win_height = api.nvim_eval("&lines") / 3 -- Adjust height as needed
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

    -- Set window options to enable wrapping
    api.nvim_win_set_option(win_id, 'wrap', true)
    api.nvim_win_set_option(win_id, 'linebreak', true)

    -- Map 'q' to close the floating window
    api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>',
        { noremap = true, silent = true })

end

api.nvim_set_keymap("n", "<leader>l", ":lua show_current_line_popup()<CR>", { noremap = true, silent = true, desc = "Show current line in popup" });
