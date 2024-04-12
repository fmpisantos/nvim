return {
    "mfussenegger/nvim-dap",
    requires = { { "williamboman/mason.nvim" } },
    config = function()
        vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<Shift-F5>', ":lua require'dap'.stop()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F9>', ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<Shift-F11>', ":lua require'dap'.step_out()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true })
    end,
}
