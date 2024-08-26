return {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require('oil').setup {
            columns = { "icon" },
            buf_options = {
                buflisted = false,
                bufhidden = "hide",
            },
            keymaps = {
                ["<C-h>"] = false,
                ["<Tab>"] = "actions.preview",
                ["<C-v>"] = "actions.select_vsplit",
            },
            preview = {
                width = 0.8,
                height = 1,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
                -- Whether the preview window is automatically updated when the cursor is moved
                update_on_cursor_moved = true,
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
    end,
}
