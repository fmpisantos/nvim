return {
    src = "fmpisantos/opencode.nvim",
    deps = {
        "nvim-telescope/telescope.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-lua/plenary.nvim"
    },
    setup = function()
        require("opencode").setup({
            timeout_ms = 300000
        })
    end
}
