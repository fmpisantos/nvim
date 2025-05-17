return {
    "mfussenegger/nvim-dap",
    requires = { { "williamboman/mason.nvim" } },
    config = function()
        _G.Dap = require('dap')

        -- Dap.configurations.java = {
        --     {
        --         type = 'java',
        --         request = 'attach',
        --         name = "Debug (Attach) - Remote",
        --         hostName = "127.0.0.1",
        --         port = 5005,
        --     },

        Dap.adapters.coreclr = {
            type = 'executable',
            command = 'F:\\netcorebg\\netcoredbg.exe',
            args = { '--interpreter=vscode' }
        }

        local function find_highest_net_version()
            local debug_path = vim.fn.getcwd() .. '\\bin\\Debug\\'
            local dirs = vim.fn.glob(debug_path .. 'net*', 0, 1)

            if #dirs == 0 then
                vim.notify("No net* folders found in bin\\Debug\\", vim.log.levels.ERROR)
                return ''
            end

            table.sort(dirs, function(a, b)
                local major_a, minor_a = a:match("net(%d+)%.(%d+)")
                local major_b, minor_b = b:match("net(%d+)%.(%d+)")

                if major_a and major_b then
                    major_a, minor_a = tonumber(major_a), tonumber(minor_a)
                    major_b, minor_b = tonumber(major_b), tonumber(minor_b)

                    if major_a == major_b then
                        return minor_a < minor_b
                    else
                        return major_a < major_b
                    end
                end

                return a < b
            end)

            return dirs[#dirs] .. '\\'
        end

        Dap.configurations.cs = {
            {
                type = 'coreclr',
                name = 'Launch - netcoredbg',
                request = 'launch',
                program = function()
                    local dir = find_highest_net_version()
                    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                    local dll = dir .. project_name .. ".dll"
                    return dll
                end,
            },
        }

        Dap.configurations.scala = {
            {
                type = "scala",
                request = "launch",
                name = "Run or Test Target",
                metals = {
                    runType = "runOrTestFile",
                },
            },
        }


        local function compile_mvn()
            local handle = io.popen('mvn clean install -DskipTests 2>&1')
            if handle then
                local result = handle:read('*a')
                handle:close()
                if result then
                    print('Maven compilation error:\n' .. result)
                else
                    vim.api.nvim_err_writeln('Failed to read Maven compilation output')
                end
            else
                vim.api.nvim_err_writeln('Failed to execute mvn compile')
            end
        end

        local jdtls = require("jdtls");

        vim.keymap.set('n', '<leader>Dr', function()
                compile_mvn(); Dap.run_last()
            end,
            { noremap = true, desc = "Debug run_last" })

        vim.keymap.set('n', "<leader>Dc", function()
            compile_mvn(); jdtls.test_class()
        end, { desc = "[D]ebug [C]lass" })

        vim.keymap.set('n', '<leader>Dm', function()
                compile_mvn(); jdtls.test_nearest_method()
            end,
            { desc = '[D]ebug [M]ethod' })

        vim.keymap.set("n", "<leader>Dl", function() jdtls.pick_test() end,
            { desc = "[D]ebug pick tests" })


        vim.keymap.set('n', '<F5>', function()
            if Dap.session() == nil then
                compile_mvn();
            end
            Dap.continue()
        end, { noremap = true, desc = "Degub Continue" })

        vim.keymap.set('n', '<S-F5>', function() Dap.terminate() end, { noremap = true, desc = "Debug Stop" })

        vim.keymap.set('n', '<C-S-F5>', function()
            Dap.terminate(); compile_mvn(); Dap.run_last();
        end, { noremap = true, desc = "Debug Stop" })

        vim.keymap.set('n', '<F9>', function() Dap.toggle_breakpoint() end,
            { noremap = true, desc = "Debug Toggle Breakpoint" })

        vim.keymap.set('n', '<F10>', function() Dap.step_over() end,
            { noremap = true, desc = "Debug Step Over" })

        vim.keymap.set('n', '<S-F11>', function() Dap.step_out() end,
            { noremap = true, desc = "Debug Step Out" })

        vim.keymap.set('n', '<F11>', function() Dap.step_into() end,
            { noremap = true, desc = "Debug Step Into" })

        vim.api.nvim_create_user_command("DapClearBreakpoints", function()
            Dap.clear_breakpoints()
        end, { desc = "Clear all breakpoints" })

        vim.api.nvim_create_user_command("DapRepl", function()
            Dap.repl.open()
        end, { desc = "Open REPL" })

        local function mvnnt()
            require("awman.plugins.java.config").clear_data_dir();
            compile_mvn();
        end
        vim.api.nvim_create_user_command("Mvnnt", mvnnt, { desc = "Maven clean install with no tests" })
        vim.api.nvim_create_user_command("DapCleanInstall", mvnnt, { desc = "Maven clean install with no tests" })
    end,
}
