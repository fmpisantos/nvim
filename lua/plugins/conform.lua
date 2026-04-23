return {
    src = {
        "stevearc/conform.nvim"
    },
    setup = function()
        require("conform").setup({
            formatters_by_ft = {
                html = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
            },
        })

        vim.api.nvim_create_user_command("ConformFormat", function()
            require("conform").format()
        end, { desc = "Format the current buffer with conform.nvim" })
    end
}
