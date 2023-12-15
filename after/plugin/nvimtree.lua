-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
-- empty setup using defaults
-- require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
    view = {
        width = 30,
    },
    filters = {
        dotfiles = false
    },
    update_focused_file = { enable = true }
})

vim.keymap.set("n", "<leader>sb", "<cmd>:NvimTreeToggle<CR>", {--[[Toggle SideBar]]});
vim.keymap.set("n", "<leader>pv", "<cmd>:NvimTreeToggle<CR>", {--[[Toggle SideBar]]});
