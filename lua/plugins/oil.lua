return {
    src = "stevearc/oil.nvim",
    setup = function()
        local oil = require("oil")
        local actions = require("oil.actions")

        local show_details = false

        local function toggle_columns()
            show_details = not show_details
            if show_details then
                oil.set_columns({ "icon", "permissions", "size", "mtime" })
            else
                oil.set_columns({ "icon" })
            end
            actions.refresh.callback()
        end

        oil.setup({
            keymaps = {
                ["<C-h>"] = false,
                ["<Tab>"] = "actions.preview",
                ["<C-v>"] = "actions.select_vsplit",
                -- Use `i` to toggle detailed columns like netrw
                ["i"] = toggle_columns,
            },
            view_options = {
                show_hidden = true,
                is_hidden_file = function(name, _)
                    return vim.startswith(name, ".")
                end,
                is_always_hidden = function(_, _)
                    return false
                end,
            },
            skip_confirm_for_simple_edits = true,
            columns = { "icon" }, -- start minimal
        })

        vim.keymap.set("n", "-", oil.open, { noremap = true, silent = true, desc = "Open file" })
        vim.keymap.set("n", "<leader>pv", oil.open,
            { noremap = true, silent = true, desc = "Open parent directory" })
    end,
}
