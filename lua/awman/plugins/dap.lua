return {
    "mfussenegger/nvim-dap",
    requires = { { "williamboman/mason.nvim" } },
    config = function()
        local dap = require('dap')

        dap.configurations.java = {
            {
                type = 'java',
                request = 'attach',
                name = "Debug (Attach) - Remote",
                hostName = "127.0.0.1",
                port = 5005,
            },
        }

        -- Key mappings for debugging
        local jdtls = require("jdtls");
        vim.keymap.set('n', "<leader>dc", function() jdtls.test_class() end, { desc = "[D]ebug [C]lass" })
        vim.keymap.set('n', '<leader>dm', function() require('jdtls').test_nearest_method() end,
            { desc = '[D]ebug [M]ethod' })
        vim.keymap.set('n', '<F5>', function() dap.continue() end, { noremap = true, desc = "Degub Continue" })
        vim.keymap.set('n', '<Shift-F5>', function() dap.stop() end, { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end,
            { noremap = true, desc = "Debug Toggle Breakpoint" })
        vim.keymap.set('n', '<F10>', function() dap.step_over() end, { noremap = true, desc = "Debug Step Over" })
        vim.keymap.set('n', '<Shift-F11>', function() dap.step_out() end, { noremap = true, desc = "Debug Step Out" })
        vim.keymap.set('n', '<F11>', function() dap.step_into() end, { noremap = true, desc = "Debug Step Into" })
    end,
}
