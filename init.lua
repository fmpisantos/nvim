vim.g.lazy_flatten_excluded_dirs = {
    'lua/awman/plugins/ignore'
}
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.cmd("wshada!")
  end,
})
require("awman")
require("sihot")
