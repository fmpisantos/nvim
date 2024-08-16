return {
    "kwakzalver/duckytype.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
    branch = "main",
    config = function()
        require("duckytype").setup({
            number_of_words = 25,
            highlight = {
                good = "Normal",
                bad = "Error",
                remaining = "Comment"
            }
        })
    end,
}
