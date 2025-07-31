-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = ' '

require("set")
require("remap")


-- Packages
vim.pack.add({
	{ src = 'https://github.com/folke/neodev.nvim' },
});

-- Setups
require("plugins");
