return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        vim.keymap.set('n', '<leader>tt', function() require("trouble").toggle() end, {desc = "[T]rouble [T]oggle"})
        vim.keymap.set('n', '<leader>tpr', function() require("trouble").toggle("workspace_diagnostics") end, {desc = "[T]rouble [P]roject [R]efresh"})
        vim.keymap.set('n', '<leader>tr', function() require("trouble").toggle("document_diagnostics") end, {desc = "[T]rouble [D]ocument [R]efresh"})
        vim.keymap.set('n', '<leader>tdr', function() require("trouble").toggle("document_diagnostics") end, {desc = "[T]rouble [D]ocument [R]efresh"})
        vim.keymap.set('n', '<leader>tl', function() require("trouble").toggle("quickfix") end, {desc = "[T]rouble [L]ist"})
    end,
}
