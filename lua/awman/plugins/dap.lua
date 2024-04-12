return {
    "mfussenegger/nvim-dap",
    requires = { { "williamboman/mason.nvim" } },
    config = function()
        local dap = require('dap')

        -- Java debugger configuration
        dap.adapters.java = {
            type = 'executable',
            command = 'java',
            args = { '-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005' },
            env = {
                JAVA_HOME = os.getenv('JAVA_HOME')
            },
            name = "Java"
        }

        dap.configurations.java = {
          {
            type = 'java',
            request = 'attach',
            name = "Debug (Attach) - Remote",
            hostName = "127.0.0.1",
            port = 5005,
          },
        }
        --
        -- dap.configurations.java = {
        --     {
        --         type = 'java',
        --         name = 'Debug (Launch)',
        --         request = 'launch',
        --         cwd = '${workspaceFolder}',
        --         startup = "${file}",
        --         stopOnEntry = true,
        --         classpath = '${workspaceFolder}/bin',
        --         options = {
        --             classpath = '${workspaceFolder}/bin'
        --         }
        --     }
        -- }

        -- Key mappings for debugging
        vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<Shift-F5>', ":lua require'dap'.stop()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F9>', ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<Shift-F11>', ":lua require'dap'.step_out()<CR>", { noremap = true })
        vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true })
    end,
}
