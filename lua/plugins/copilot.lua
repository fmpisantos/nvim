return {
    src = "CopilotC-Nvim/CopilotChat.nvim",
    deps = {
        "zbirenbaum/copilot.lua",
    },
    setup = function()
        local copilot = require("copilot")

        copilot.setup({
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = false,
                    accept_word = false,
                    accept_line = false,
                    next = false,
                    prev = false,
                    dismiss = false,
                },
            },
            panel = {
                enabled = false,
            },
        })

        require("CopilotChat").setup()

        vim.keymap.set("n", "<C-c><C-c>", "<cmd>CopilotChat<CR>", { noremap = true, silent = true })
        vim.keymap.set("v", "CC", function()
            local mode = vim.fn.mode()
            local start_pos = vim.fn.getpos("v")
            local end_pos = vim.fn.getpos(".")
            local selection_lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
            local filetype = vim.bo.filetype

            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

            local width = 60
            local height = 10
            local buf = vim.api.nvim_create_buf(false, true)
            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                col = (vim.o.columns - width) / 2,
                row = (vim.o.lines - height) / 2,
                style = "minimal",
                border = "rounded",
                title = " CopilotChat Prompt ",
                title_pos = "center",
            })

            vim.bo[buf].buftype = "acwrite"
            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].filetype = "markdown"
            vim.api.nvim_buf_set_name(buf, "CopilotChat Prompt")

            local initial_lines = { "```" .. filetype }
            vim.list_extend(initial_lines, selection_lines)
            vim.list_extend(initial_lines, { "```", "" })
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_lines)

            vim.api.nvim_win_set_cursor(win, { #initial_lines, 0 })
            vim.cmd("startinsert")

            local function submit_prompt()
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local content = table.concat(lines, "\n")
                vim.api.nvim_win_close(win, true)
                if content and content ~= "" then
                    require("CopilotChat").ask(content)
                end
            end

            vim.api.nvim_create_autocmd("BufWriteCmd", {
                buffer = buf,
                callback = function()
                    submit_prompt()
                end,
            })

            vim.keymap.set("c", "wq", function()
                if vim.fn.getcmdtype() == ":" and vim.api.nvim_get_current_buf() == buf then
                    submit_prompt()
                    return ""
                end
                return "wq"
            end, { buffer = buf, expr = true })

            vim.keymap.set("n", "q", function()
                vim.api.nvim_win_close(win, true)
            end, { buffer = buf, noremap = true, silent = true })
            vim.keymap.set("n", "<Esc>", function()
                vim.api.nvim_win_close(win, true)
            end, { buffer = buf, noremap = true, silent = true })
        end, { noremap = true, silent = true, desc = "CopilotChat with floating prompt" })
        vim.keymap.set("i", "<C-c><C-a>", function() require("copilot.suggestion").accept() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-l>", function() require("copilot.suggestion").accept_line() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-w>", function() require("copilot.suggestion").accept_word() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-n>", function() require("copilot.suggestion").next() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-p>", function() require("copilot.suggestion").prev() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-d>", function() require("copilot.suggestion").dismiss() end,
            { noremap = true, silent = true })
        vim.keymap.set("i", "<C-c><C-s>", function() require("copilot.suggestion").toggle_auto_trigger() end,
            { noremap = true, silent = true })
        vim.keymap.set("n", "<C-c><C-p>", "<cmd>Copilot panel<CR>", { noremap = true, silent = true })
    end,
}
