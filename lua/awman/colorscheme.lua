vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = 'white' })
        -- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = 'orange' })
        vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = '#ffffff' })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = '#4b5263' })
    end,
})
-- vim.cmd.highlight("LineNr", { guifg = "#4b5263" })

-- vim.cmd.colorscheme 'catppuccin-frappe'
vim.cmd.colorscheme 'catppuccin-macchiato'
-- vim.cmd.colorscheme 'catppuccin-mocha'

-- vim.o.background = "light"
-- vim.cmd.colorscheme "neg"

vim.cmd.colorscheme("tokyonight-storm")
-- vim.cmd.colorscheme("tokyonight-moon")
-- vim.cmd.colorscheme("tokyonight-night")

-- vim.cmd.colorscheme("rose-pine-main")
-- vim.cmd.colorscheme("rose-pine-moon")

-- vim.cmd.colorscheme("monochrome")

-- vim.cmd.colorscheme("nordern")
