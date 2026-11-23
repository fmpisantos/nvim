return {
    src = { "kdheepak/lazygit.nvim" },
    deps = { "nvim-lua/plenary.nvim" },
    setup = function()
        vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>",
            { noremap = true, silent = true, desc = "Open LazyGit" });
        -- Commands
        -- "LazyGit",
        -- "LazyGitConfig",
        -- "LazyGitCurrentFile",
        -- "LazyGitFilter",
        -- "LazyGitFilterCurrentFile",
    end
}
