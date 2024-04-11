local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
    -- {
    --     -- Set lualine as statusline
    --     'nvim-lualine/lualine.nvim',
    --     -- See `:help lualine.txt`
    --     opts = {
    --         options = {
    --             icons_enabled = false,
    --             theme = 'ayu_mirage',
    --             component_separators = '|',
    --             section_separators = '',
    --         },
    --     },
    -- },
    -- {
    --     'liuchengxu/space-vim-dark',
    --     config = function()
    --         vim.cmd('colorscheme space-vim-dark')
    --         vim.cmd('hi Comment guifg=#5C6370 ctermfg=59')
    --     end,
    -- },
    { import = "awman.plugins" },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            -- your custom plugins
            options = {
                flavour = "mocha"
            }
        },
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end
    },
}, {});
