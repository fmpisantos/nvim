return {
    "fmpisantos/notes.nvim",
    dependencies = {
        "stevearc/oil.nvim",
        "fmpisantos/shared_buffer.nvim",
        "fmpisantos/oilAutoCmd.nvim"
    },
    config = function()
        local notes = require("notes");
        notes.setup();
    end
}
