return {
    "ldelossa/gh.nvim",
    dependencies = {
        {
            "ldelossa/litee.nvim",
            config = function()
                require("litee.lib").setup()
            end,
        },
    },
    config = function()
        require("litee.gh").setup()
        vim.keymap.set("n", "<leader>pr", "<cmd>GHOpenPR<cr>", { desc = "Open [P]ull [R]equest" });
    end,
}
