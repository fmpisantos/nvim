return {
    src = "fmpisantos/opencode.nvim",
    -- dev = true,
    deps = {
        "nvim-telescope/telescope.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-lua/plenary.nvim",
        "fmpisantos/shared_buffer.nvim"
    },
    setup = function()
        require("opencode").setup({
            timeout_ms = -1
        })
    end
}
