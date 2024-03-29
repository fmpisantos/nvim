function vim.getVisualSelection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ''
    end
end

return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    --  tag = '0.1.x'
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "[P]roject [F]ile" });
        vim.keymap.set('v', '<leader>pf', function()
            local text = vim.getVisualSelection()
            builtin.find_files({ default_text = text })
        end, { desc = "[P]roject [F]ile" });

        vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = "[P]roject [G]rep" });
        vim.keymap.set('v', '<leader>pg', function()
            local text = vim.getVisualSelection()
            builtin.live_grep({ default_text = text })
        end, { desc = "[P]roject [G]rep" });

        vim.keymap.set('n', '<leader>dg', function() builtin.live_grep({ search_dirs = { vim.fn.expand("%:p") } }) end,
            { desc = "[D]ocument [G]rep" });
        vim.keymap.set('v', '<leader>dg', function()
            local text = vim.getVisualSelection()
            builtin.live_grep({ search_dirs = { vim.fn.expand("%:p") }, default_text = text })
        end, { desc = "[D]ocument [G]rep" });

        vim.keymap.set('n', '<leader>fg', function() builtin.live_grep({ search_dirs = { vim.fn.expand("%:h") } }) end,
            { desc = "[F]older [G]rep" });
        vim.keymap.set('v', '<leader>fg', function()
            local text = vim.getVisualSelection()
            builtin.live_grep({ search_dirs = { vim.fn.expand("%:h") }, default_text = text })
        end, { desc = "[F]older [G]rep" });

        -- search over the tags of the current buffer attached lsp server
        vim.keymap.set('n', '<leader>?', builtin.lsp_workspace_symbols, { desc = "[P]roject [T]ags" });

        vim.keymap.set('n', '<leader><leader>', "<cmd>:Telescope keymaps<CR>", { desc = "Grep over keymaps" });
    end
}
