vim.pack.add({
    { src = "https://github.com/fmpisantos/notes.nvim" },
    { src = "https://github.com/fmpisantos/oil.nvim" },
    { src = "https://github.com/fmpisantos/shared_buffer.nvim" },
    { src = "https://github.com/fmpisantos/oilAutoCmd.nvim" },
});

require("notes").setup();
