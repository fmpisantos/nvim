return {
    'theprimeagen/harpoon',
    branch = "harpoon2",
    requires = { {"nvim-lua/plenary.nvim"} },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()

        vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "[A]dd file to harpoon list"});
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[E]dit harpoon list"});

        vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Goto file in [h] position"});
        vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Goto file in [j] position"});
        vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Goto file in [k] position"});
        vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Goto file in [l] position"});
    end
}
