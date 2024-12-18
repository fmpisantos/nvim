local state = {
    floating = {
        buf = -1,
        win = -1
    }
}

vim.keymap.set({ 'n', 't' }, "<leader>tf", function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = CreateFloatingTerminal { buf = state.floating.buf }
        if vim.api.nvim_buf_get_option(state.floating.buf, "buftype") ~= "terminal" then
            vim.cmd.terminal()
        end
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end, { noremap = true, silent = true, desc = "Open floating terminal" })
