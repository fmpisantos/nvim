return {
    src = {
        "folke/tokyonight.nvim",
        "vague2k/vague.nvim",
        "rose-pine/neovim"
    },
    setup = function()
        require("rose-pine").setup({
            variant = "moon", -- auto, main, moon, or dawn
            dark_variant = "moon", -- main, moon, or dawn
        })
        vim.cmd.colorscheme("rose-pine")

        -- vim.cmd.colorscheme("tokyonight-night")
        vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = 'white' })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = 'orange' })
        vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = 'white' })

        -- vim.cmd.colorscheme("vague");

        -- Ensure background transparency works
        vim.cmd([[
          highlight Normal guibg=NONE ctermbg=NONE
          highlight NonText guibg=NONE ctermbg=NONE
          highlight SignColumn guibg=NONE ctermbg=NONE
          highlight EndOfBuffer guibg=NONE ctermbg=NONE
        ]])
    end
}
