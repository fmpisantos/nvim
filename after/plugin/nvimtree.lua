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
    dotfiles = true,
  },
})
