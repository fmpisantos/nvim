vim.pack.add({
		{src = 'https://github.com/nvim-treesitter/nvim-treesitter'},
		{src = 'https://github.com/nvim-treesitter/nvim-treesitter-context'},
});

require('nvim-treesitter.install').prefer_git = true
require('nvim-treesitter.configs').setup({
ensure_installed = { 'bash', 'c', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
auto_install = true,
highlight = {
        enable = true,
            additional_vim_regex_highlighting = { "markdown" },
        },
        indent = { enable = true },
});
