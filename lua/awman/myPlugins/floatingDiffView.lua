local state = {
    floating = {
        bufs = { -1, -1 },
        wins = { -1, -1 }
    }
}

vim.keymap.set({ 'n' }, "<leader>df", function()
    local ui = vim.api.nvim_list_uis()[1]
    if not ui then
        vim.notify("Unable to get UI dimensions!", vim.log.levels.ERROR)
        return
    end

    local width = math.floor(ui.width * 0.48)
    local height = math.floor(ui.height * 0.95)
    local col = 2
    local row = math.floor((ui.height - height) / 2)

    if vim.api.nvim_win_is_valid(state.floating.wins[1]) then
        vim.api.nvim_win_hide(state.floating.wins[1])
        vim.api.nvim_win_hide(state.floating.wins[2])
    else
        local first_win = CreateFloatingWindow { buf = state.floating.bufs[1], width = width, height = height, col = col, row = row }

        if first_win == nil then
            return
        end

        vim.cmd("diffthis")
        local _buf = state.floating.bufs[2]

        if not vim.api.nvim_buf_is_valid(_buf) then
            _buf = vim.api.nvim_create_buf(false, true)
            state.floating.bufs = { first_win.buf, _buf }
        end

        local second_win = CreateFloatingWindow { buf = _buf, width = width, height = height, col = 2 * col + width, row = row }

        if second_win == nil then
            return
        end

        vim.cmd("diffthis")

        state.floating.bufs = { first_win.buf, second_win.buf }
        state.floating.wins = { first_win.win, second_win.win }
    end
end, { noremap = true, silent = true, desc = "Open floating diff" })

vim.keymap.set({ 'v' }, "<leader>d1", function()
    local lines = _G.GetSelectedText(true);
    if not vim.api.nvim_buf_is_valid(state.floating.bufs[1]) then
        state.floating.bufs[1] = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(state.floating.bufs[1], 0, -1, false, lines)
end, { noremap = true, silent = true, desc = "Diff fill window 1" })

vim.keymap.set({ 'v' }, "<leader>d2", function()
    local lines = _G.GetSelectedText(true);
    if not vim.api.nvim_buf_is_valid(state.floating.bufs[2]) then
        state.floating.bufs[2] = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(state.floating.bufs[2], 0, -1, false, lines)
end, { noremap = true, silent = true, desc = "Diff fill window 2" })
