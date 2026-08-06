-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = " "

-- Auto format on save (default: off). Toggle with :FormatOnSaveToggle.
if vim.g.format_on_save == nil then
    vim.g.format_on_save = false
end

vim.api.nvim_create_user_command('FormatOnSaveToggle', function()
    vim.g.format_on_save = not vim.g.format_on_save
    vim.notify('Format on save: ' .. (vim.g.format_on_save and 'ON' or 'OFF'))
end, { desc = 'Toggle auto-format on save' })

vim.api.nvim_create_user_command('FormatOnSave', function(opts)
    local arg = (opts.args or ''):lower()
    if arg == 'on' or arg == 'enable' or arg == 'true' then
        vim.g.format_on_save = true
    elseif arg == 'off' or arg == 'disable' or arg == 'false' then
        vim.g.format_on_save = false
    else
        vim.notify('Usage: :FormatOnSave on|off', vim.log.levels.WARN)
        return
    end
    vim.notify('Format on save: ' .. (vim.g.format_on_save and 'ON' or 'OFF'))
end, { nargs = 1, complete = function() return { 'on', 'off' } end, desc = 'Set auto-format on save' })

-- Debug hook: capture the full stack trace whenever vim.validate fails
-- (e.g. "t: expected table, got function"). Enabled by default; disable by
-- setting NVIM_VALIDATE_TRACE=0 in the environment.
if vim.env.NVIM_VALIDATE_TRACE ~= "0" then
    local orig_validate = vim.validate
    vim.validate = function(...)
        local ok, err = pcall(orig_validate, ...)
        if not ok then
            local trace = debug.traceback(tostring(err), 2)
            vim.schedule(function()
                vim.notify("[validate-trace]\n" .. trace, vim.log.levels.ERROR)
            end)
            error(err, 2)
        end
    end
end

require("set")
require("netrw_config")
require("remap")

if vim.env.FROM_WEZTERM == "1" then
    return
end

require("nokia")

vim.pack.add({ "https://github.com/fmpisantos/pack.nvim" })
local pack = require("pack")

require("plugins.extensions");

pack.require("plugins");
pack.require("plugins.myPlugins.init");
pack.install()

-- Force wrap
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*/Notes/PersonalNotes/notes/notesForInterview(story).md",
    callback = function()
        vim.opt_local.wrap = true
    end,
})
