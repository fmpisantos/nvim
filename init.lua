require("set")
require("remap")

-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = ' '

-- Packages
vim.pack.add({
	{ src = 'https://github.com/folke/neodev.nvim' },
});

-- Setups
require("plugins.extensions");
require("plugins.oil");
require("plugins.colorscheme");
require("plugins.undotree");
require("plugins.telescope");
require("plugins.lsp");
require("plugins.treesitter");
require("plugins.dadbod");
require("plugins.dap-ui");
require("plugins.dap");
