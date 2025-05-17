return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        vim.keymap.set('n', '<leader>et',
            function() require("trouble").toggle({ mode = "diagnostics", filter = { severity = vim.diagnostic.severity.E } }) end,
            { desc = "[T]rouble [E]rros" })
        vim.keymap.set('n', '<leader>tt',
            function() require("trouble").toggle("diagnostics", { severity = vim.diagnostic.severity.ERROR }) end,
            { desc = "[T]rouble [T]oggle" })
        vim.keymap.set('n', '<leader>tp', function() require("trouble").toggle("workspace_diagnostics") end,
            { desc = "[T]rouble [P]roject [R]efresh" })
        vim.keymap.set('n', '<leader>td', function() require("trouble").toggle("document_diagnostics") end,
            { desc = "[T]rouble [D]ocument [R]efresh" })
        vim.keymap.set('n', '<leader>tl', function() require("trouble").toggle("quickfix") end,
            { desc = "[T]rouble [L]ist" })
        vim.keymap.set('n', ']t', function() require("trouble").next({ skip_groups = true, jump = true }) end,
            { desc = "Next [D]iagnostic" })
        vim.keymap.set('n', '[t', function() require("trouble").previous({ skip_groups = true, jump = true }) end,
            { desc = "Previous [D]iagnostic" })
        vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setqflist({ open = true })<CR>',
            { noremap = true, silent = true })
        require('which-key').add({
            { '<leader>t', desc = '[T]oggle' },
        });
        require("trouble").setup({
            modes = {
                diagnostics = {
                    filter = function(items)
                        return vim.tbl_filter(function(item)
                            return not string.match(item.basename, [[%__virtual.cs$]])
                        end, items)
                    end,
                },
            },
        })
    end,
}
