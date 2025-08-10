return {
    src = "stevearc/oil.nvim",
    setup = function()
        require('oil').setup {
            keymaps = {
                ["<C-h>"] = false,
                ["<Tab>"] = "actions.preview",
                ["<C-v>"] = "actions.select_vsplit",
            },
            view_options = {
                -- Show files and directories that start with "."
                show_hidden = true,
                -- This function defines what is considered a "hidden" file
                is_hidden_file = function(name, _)
                    return vim.startswith(name, ".")
                end,
                -- This function defines what will never be shown, even when `show_hidden` is set
                is_always_hidden = function(_, _)
                    return false
                end,
            },
            skip_confirm_for_simple_edits = true,
        }
        vim.keymap.set("n", "-", require('oil').open, { noremap = true, silent = true, desc = "Open file" });
        vim.keymap.set("n", "<leader>pv", require('oil').open,
            { noremap = true, silent = true, desc = "Open parent directory" });
    end
}
