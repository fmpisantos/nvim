vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

local home_dir = os.getenv("HOME")
if not home_dir then
    home_dir = os.getenv("USERPROFILE")
end

vim.opt.undodir = home_dir .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99

-- Set the clipboard to "unnamedplus"
vim.cmd('set clipboard+=unnamedplus')
vim.o.ignorecase = true
-- set clipboard+=unnamedplus

-- Kickstart include
vim.g.have_nerd_font = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.cmd("startinsert")
    end,
})

-- MacOS only
if vim.loop.os_uname().sysname == 'Darwin' then
    vim.cmd('set shell=/bin/zsh')
    vim.cmd('set shellcmdflag=-c')
    vim.cmd('set shellquote=')
    vim.cmd('set shellxquote=')
end
