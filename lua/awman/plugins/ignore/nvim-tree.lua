return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        vim.opt.termguicolors = true
        require("nvim-tree").setup({
            view = {
                width = 30,
            },
            filters = {
                dotfiles = false
            },
            update_focused_file = { enable = true },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
            },
        })

        vim.keymap.set("n", "<leader>sb", "<cmd>:NvimTreeToggle<CR>", { desc = "Toggle [S]ide [B]ar" });
        -- vim.keymap.set("n", "<leader>pv", "<cmd>:NvimTreeToggle<CR>", { desc = "Toggle [P]roject [V]iew" });
    end
}
