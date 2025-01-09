return {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("night-owl").setup()
    end,
}
