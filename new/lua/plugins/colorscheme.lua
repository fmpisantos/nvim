return {
    src = {
        "folke/tokyonight.nvim",
        "vague2k/vague.nvim",
    },
    setup = function()
        -- vim.cmd.colorscheme("tokyonight-night")
        -- vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = 'white' })
        -- vim.api.nvim_set_hl(0, 'LineNr', { fg = 'orange' })
        -- vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = 'white' })

        vim.cmd.colorscheme("vague");
    end
}
