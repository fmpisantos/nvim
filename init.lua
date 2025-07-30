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
require("plugins");
