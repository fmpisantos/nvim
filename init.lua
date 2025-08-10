-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = " "

require("set")
require("remap")

vim.pack.add({ "https://github.com/fmpisantos/pack.nvim" })
local pack = require("pack")

require("plugins.extensions");

pack.require("plugins");
pack.require("plugins.myPlugins.init");
pack.install()
