return {
    'tpope/vim-fugitive',
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "[G]it [S]tart" });
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git commit" });
        vim.keymap.set("n", "<leader>gd", "<cmd>:Gdiff<CR>", { desc = "Git difference" });
        vim.keymap.set("n", "<leader>gh", "<cmd>diffget //2<CR>", { desc = "Use left" });
        vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>", { desc = "Use left" });
        vim.keymap.set("n", "<leader>gl", "<cmd>diffget //3<CR>", { desc = "Use righ" });
        vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>", { desc = "Use righ" });
        vim.keymap.set("n", "<leader>gc", "<cmd>:Git commit<CR>", { desc = "Git commit" });
        vim.keymap.set("n", "<leader>gp", "<cmd>:Git push -u origin<CR>", { desc = "Git commit" });
        vim.keymap.set("n", "<leader>gb", "<cmd>: Git blame<CR>", { desc = "Git blame" });
        require('which-key').add({
            { '<leader>g', desc = '[G]it' },
        });
    end
}
