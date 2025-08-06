-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = " "

require("set")
require("remap")

vim.pack.add({
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/mbbill/undotree" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
    { src = "https://github.com/theprimeagen/harpoon",                    version = "harpoon2" },
    {
        src = "https://github.com/iamcco/markdown-preview.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && yarn install && git restore ."
    },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/chentoast/marks.nvim"}
})

require("plugins.oil")
require("plugins.undotree")
require("plugins.telescope")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.harpoon")
require("plugins.fugitive")
require("plugins.marks")
-- My plugins
require("plugins.notes")
require("plugins.extensions")
require("plugins.myplugins")
require("plugins.sihot")

-- Colorscheme
require("plugins.colorscheme")
