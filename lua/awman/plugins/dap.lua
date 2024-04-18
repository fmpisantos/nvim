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

        -- local function create_directories(path)
        --     print("Creating directories for path: " .. path)
        --     local dirs = {}
        --     for dir in path:gmatch("[^/]+") do
        --         table.insert(dirs, dir)
        --         local current_path = table.concat(dirs, "/")
        --         if vim.fn.isdirectory(current_path) == 0 then
        --             vim.fn.mkdir(current_path, "p")
        --         end
        --     end
        -- end
        --
        -- local prefix = "~/.local/share/nvim/dap"
        -- create_directories(prefix)
        --
        -- local function get_current_session_dir()
        --     return prefix .. vim.fn.getcwd()
        -- end
        --
        -- local function get_current_session_file()
        --     return prefix .. vim.fn.getcwd() .. "/last_config"
        -- end
        --
        -- local function file_exists(path)
        --     local file = io.open(path, "r")
        --     if file then
        --         file:close()
        --         return true
        --     else
        --         return false
        --     end
        -- end
        --
        -- local function load_last_config()
        --     local _last_config_file = get_current_session_file()
        --     if file_exists(_last_config_file) then
        --         return dofile(_last_config_file)
        --     else
        --         return nil
        --     end
        -- end
        --
        -- _G.Last_config_file = load_last_config()
        --
        -- _G.Save_last_dap_session = function()
        --     print("Saving last DAP session")
        --     local last_config = nil
        --     require('jdtls.dap').fetch_main_configs({}, function(configurations)
        --         for _, config in ipairs(configurations) do
        --             last_config = config
        --         end
        --         if last_config then
        --             create_directories(get_current_session_dir())
        --             local file = io.open(get_current_session_file(), "w")
        --             if file then
        --                 file:write("return " .. vim.inspect(last_config))
        --                 file:close()
        --             end
        --             Last_config_file = last_config
        --             file = io.open(prefix .. "/last_config", "w")
        --             if file then
        --                 file:write("return " .. vim.inspect(last_config))
        --                 file:close()
        --             end
        --         end
        --     end)
        -- end
        --
        -- local function restart_last_dap_session()
        --     if Last_config_file then
        --         require('dap').disconnect()
        --         require('dap').run(Last_config_file)
        --     else
        --         print("No previous DAP session saved.")
        --     end
        -- end
        --
        -- -- Listen for the DebugStarted event
        -- vim.api.nvim_command('autocmd User DapStarted lua Save_last_dap_session()')

        -- Key mappings for debugging

        local jdtls = require("jdtls");
        -- local jdtls_dap = require("jdtls.dap");
        -- vim.keymap.set('n', '<leader>dr', function() jdtls_dap.restart() end,
        --     { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', "<leader>dc", function()
            jdtls.test_class()
        end, { desc = "[D]ebug [C]lass" })
        vim.keymap.set('n', '<leader>dm', function()
            require('jdtls').test_nearest_method()
        end, { desc = '[D]ebug [M]ethod' })
        vim.keymap.set('n', '<F5>', function()
            dap.continue()
        end, { noremap = true, desc = "Degub Continue" })
        vim.keymap.set('n', '<S-F5>', function() dap.terminate() end, { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', '<C-S-F5>', function() dap.restart() end,
            { noremap = true, desc = "Debug Stop" })
        vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end,
            { noremap = true, desc = "Debug Toggle Breakpoint" })
        vim.keymap.set('n', '<F10>', function() dap.step_over() end, { noremap = true, desc = "Debug Step Over" })
        vim.keymap.set('n', '<S-F11>', function() dap.step_out() end, { noremap = true, desc = "Debug Step Out" })
        vim.keymap.set('n', '<F11>', function() dap.step_into() end, { noremap = true, desc = "Debug Step Into" })
    end,
}
