vim.g.lazy_flatten_excluded_dirs = {
    'lua/awman/plugins/ignore'
}
-- Set shell to PowerShell
vim.opt.shell = 'powershell.exe'

-- Use -Command to run commands
vim.opt.shellcmdflag = '-Command'

-- Ensure shellquote and shellxquote are empty
vim.opt.shellquote = ''
vim.opt.shellxquote = ''
require("awman")
require("sihot")
