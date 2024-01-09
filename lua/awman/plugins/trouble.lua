return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        vim.keymap.set('n', '<leader>tt', function() require("trouble").toggle() end, {desc = "[T]rouble [T]oggle"})
        vim.keymap.set('n', '<leader>tpr', function() require("trouble").toggle("workspace_diagnostics") end, {desc = "[T]rouble [P]roject [R]efresh"})
        vim.keymap.set('n', '<leader>tr', function() require("trouble").toggle("document_diagnostics") end, {desc = "[T]rouble [D]ocument [R]efresh"})
        vim.keymap.set('n', '<leader>tdr', function() require("trouble").toggle("document_diagnostics") end, {desc = "[T]rouble [D]ocument [R]efresh"})
        vim.keymap.set('n', '<leader>tl', function() require("trouble").toggle("quickfix") end, {desc = "[T]rouble [L]ist"})
        vim.keymap.set('n', ']d', function() require("trouble").next({skip_groups = true, jump = true}) end, {desc = "Next [D]iagnostic"})
        vim.keymap.set('n', '[d', function() require("trouble").previous({skip_groups = true, jump = true}) end, {desc = "Previous [D]iagnostic"})
    end,
}
