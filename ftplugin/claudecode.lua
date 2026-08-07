-- =============================================================================
-- Filetype plugin for claude_code prompt buffers
-- =============================================================================
-- Provides an @ trigger for fuzzy file references and #buffer/#buf expansion.

if vim.b.did_ftplugin_claudecode then
    return
end
vim.b.did_ftplugin_claudecode = true

--- Insert a file reference at the cursor using the Telescope file picker
local function insert_file_reference()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("telescope.nvim is required for file references", vim.log.levels.ERROR)
        return
    end

    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local target_buf = vim.api.nvim_get_current_buf()
    local target_win = vim.api.nvim_get_current_win()

    builtin.find_files({
        hidden = true,
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if not selection then
                    return
                end
                local filepath = selection[1] or selection.value
                if not filepath then
                    return
                end
                if not vim.api.nvim_buf_is_valid(target_buf) or not vim.api.nvim_win_is_valid(target_win) then
                    return
                end

                vim.api.nvim_set_current_win(target_win)
                local row, col = unpack(vim.api.nvim_win_get_cursor(target_win))
                local line = vim.api.nvim_buf_get_lines(target_buf, row - 1, row, false)[1]
                local before_cursor = line:sub(1, col)
                local after_cursor = line:sub(col + 1)
                local wrapped_path, new_line
                if before_cursor:match("@$") then
                    local before_at = before_cursor:sub(1, -2)
                    wrapped_path = "`@" .. filepath .. "`"
                    new_line = before_at .. wrapped_path .. " " .. after_cursor
                    vim.api.nvim_buf_set_lines(target_buf, row - 1, row, false, { new_line })
                    vim.api.nvim_win_set_cursor(target_win, { row, #before_at + #wrapped_path + 1 })
                else
                    wrapped_path = "`@" .. filepath .. "`"
                    new_line = before_cursor .. wrapped_path .. " " .. after_cursor
                    vim.api.nvim_buf_set_lines(target_buf, row - 1, row, false, { new_line })
                    vim.api.nvim_win_set_cursor(target_win, { row, col + #wrapped_path + 1 })
                end

                vim.schedule(function()
                    vim.cmd("startinsert!")
                end)
            end)
            return true
        end,
    })
end

--- Replace #buffer / #buf shortcuts with an @path reference to the source file
---@return boolean success
local function try_replace_buffer_shortcut()
    local source_file = vim.b.claude_code_source_file
    if not source_file or source_file == "" then
        return false
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local before_cursor = line:sub(1, col)

    local pattern, replacement
    if before_cursor:match("#buffer$") then
        pattern = "#buffer$"
        replacement = "`@" .. source_file .. "`"
    elseif before_cursor:match("#buf$") then
        pattern = "#buf$"
        replacement = "`@" .. source_file .. "`"
    else
        return false
    end

    local new_before = before_cursor:gsub(pattern, replacement)
    local new_line = new_before .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, #new_before })
    return true
end

vim.keymap.set("i", "@", function()
    vim.api.nvim_feedkeys("@", "n", false)
    vim.schedule(insert_file_reference)
end, { buffer = true, noremap = true, silent = true, desc = "Insert file reference with fuzzy finder" })

vim.keymap.set("i", "<Space>", function()
    try_replace_buffer_shortcut()
    vim.api.nvim_feedkeys(" ", "n", false)
end, { buffer = true, noremap = true, silent = true, desc = "Replace #buffer/#buf with source file" })

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.swapfile = false
vim.opt_local.undofile = false
