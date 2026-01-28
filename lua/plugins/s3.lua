return {
    src = "fmpisantos/s3.nvim",
    deps = {
        "nvim-telescope/telescope.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-lua/plenary.nvim",
    },
    setup = function()
        require("s3").setup({
            bucket = "teamsantos-static-websites",
            profile = "static-websites"
        })
    end
}
