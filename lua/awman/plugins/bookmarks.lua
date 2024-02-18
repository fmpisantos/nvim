return {
    'tomasky/bookmarks.nvim',
    config = function()
        vim.keymap.set("n", "<leader>bm", function() require("bookmarks").bookmark_toggle() end,
            { desc = "add or remove bookmark at current line" });
        vim.keymap.set("n", "<leader>bi", function() require("bookmarks").bookmark_toggle() end,
            { desc = "add or remove bookmark at current line" });
        vim.keymap.set("n", "<leader>bme", function() require("bookmarks").bookmark_ann() end,
            { desc = "add or edit mark annotation at current line" });
        vim.keymap.set("n", "<leader>be", function() require("bookmarks").bookmark_ann() end,
            { desc = "add or edit mark annotation at current line" });
        vim.keymap.set("n", "<leader>bc", function() require("bookmarks").bookmark_clean() end,
            { desc = "clean all marks in local buffer" });
        vim.keymap.set("n", "<leader>bn", function() require("bookmarks").bookmark_next() end,
            { desc = "jump to next mark in local buffer" });
        vim.keymap.set("n", "<leader>bp", function() require("bookmarks").bookmark_prev() end,
            { desc = "jump to previous mark in local buffer" });
        vim.keymap.set("n", "<leader>bl", function() require("bookmarks").bookmark_list() end,
            { desc = "show marked file list in quickfix window" });
        require('bookmarks').setup {
            -- sign_priority = 8,  --set bookmark sign priority to cover other sign
            save_file = vim.fn.expand "$HOME/.bookmarks", -- bookmarks save file path
            keywords = {
                ["@t"] = "☑️ ", -- mark annotation startswith @t ,signs this icon as `Todo`
                ["@w"] = "⚠️ ", -- mark annotation startswith @w ,signs this icon as `Warn`
                ["@f"] = "⛏ ", -- mark annotation startswith @f ,signs this icon as `Fix`
                ["@n"] = " ", -- mark annotation startswith @n ,signs this icon as `Note`
            },
        }
    end
}
