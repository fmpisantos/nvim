return {
    "mfussenegger/nvim-dap",
    requires = { { "williamboman/mason.nvim" } },
    config = function()
        _G.Dap = require('dap')

        Dap.configurations.java = {
            {
                type = 'java',
                request = 'attach',
                name = "Debug (Attach) - Remote",
                hostName = "127.0.0.1",
                port = 5005,
            },
        }
        local jdtls = require("jdtls");
        vim.keymap.set('n', '<leader>dr', function() Dap.run_last() end, { noremap = true, desc = "Debug run_last" })
        vim.keymap.set('n', "<leader>dc", function() jdtls.test_class() end, { desc = "[D]ebug [C]lass" }) 
        vim.keymap.set('n', '<leader>dm', function() require('jdtls').test_nearest_method() end, { desc = '[D]ebug [M]ethod' })
        vim.keymap.set('n', '<F5>', function() Dap.continue() end, { noremap = true, desc = "Degub Continue" })
        vim.keymap.set('n', '<S-F5>', function() Dap.terminate() end, { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', '<C-S-F5>', function() Dap.terminate();Dap.run_last(); end, { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', '<F9>', function() Dap.toggle_breakpoint() end, { noremap = true, desc = "Debug Toggle Breakpoint" })
        vim.keymap.set('n', '<F10>', function() Dap.step_over() end, { noremap = true, desc = "Debug Step Over" })
        vim.keymap.set('n', '<S-F11>', function() Dap.step_out() end, { noremap = true, desc = "Debug Step Out" })
        vim.keymap.set('n', '<F11>', function() Dap.step_into() end, { noremap = true, desc = "Debug Step Into" })
    end,
}
