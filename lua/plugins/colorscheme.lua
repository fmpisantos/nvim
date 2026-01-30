return {
    src = {
        -- "folke/tokyonight.nvim",
        -- "vague2k/vague.nvim",
        "rose-pine/neovim"
    },
    setup = function()
        -- vim.cmd.colorscheme("tokyonight-night")
        -- vim.cmd.colorscheme("vague");
        vim.cmd.colorscheme("rose-pine")
        vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = 'white' })
        vim.api.nvim_set_hl(0, 'LineNr', { fg = 'orange' })
        vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = 'white' })

        -- Ensure background transparency works
        vim.cmd([[
          highlight Normal guibg=NONE ctermbg=NONE
          highlight NonText guibg=NONE ctermbg=NONE
          highlight SignColumn guibg=NONE ctermbg=NONE
          highlight EndOfBuffer guibg=NONE ctermbg=NONE
          ]])
    end
}
