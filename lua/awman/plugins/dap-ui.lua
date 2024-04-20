return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio"
    },
    config = function()
        require("neodev").setup({
            library = { plugins = { "nvim-dap-ui" }, types = true },
        })

        local dap, dapui = require("dap"), require("dapui")

        dapui.setup({
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "",
                    pause = "",
                    play = "",
                    run_last = "",
                    step_back = "",
                    step_into = "",
                    step_out = "",
                    step_over = "",
                    terminate = ""
                }
            },
            element_mappings = {},
            expand_lines = true,
            floating = {
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" }
                }
            },
            force_buffers = true,
            icons = {
                collapsed = "",
                current_frame = "",
                expanded = ""
            },
            layouts = {
                {
                    elements = {
                        {
                            id = "console",
                            size = 0.5
                        },
                        {
                            id = "stacks",
                            size = 0.5
                        },
                    },
                    position = "left",
                    size = 30
                }, {
                elements = {
                    {
                        id = "watches",
                        size = 0.5
                    },
                    {
                        id = "scopes",
                        size = 0.5
                    },
                },
                position = "bottom",
                size = 10
            } },
            mappings = {
                edit = "e",
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                repl = "r",
                toggle = "t",
            },
            render = {
                indent = 1,
                max_value_lines = 100
            }
        })

        vim.keymap.set('n', '<leader>dw', function() dapui.elements.watches.add() end, { noremap = true, silent = true })
        vim.keymap.set('n', '<S-F9>', function() dapui.eval() end, { noremap = true, silent = true })

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end
}
