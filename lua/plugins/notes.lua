return {
    src = {
        "https://github.com/fmpisantos/notes.nvim",
        "https://github.com/fmpisantos/shared_buffer.nvim",
        "https://github.com/fmpisantos/oilAutoCmd.nvim"
    },
    setup = function()
        require("notes").setup();
    end
}
