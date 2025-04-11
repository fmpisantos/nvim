return {
    "scalameta/nvim-metals",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
        local metals_config = require("metals").bare_config()
        metals_config.on_attach = function(_, bufnr)
            local xmap = function(type, keys, func, desc)
                if desc then
                    desc = 'LSP: ' .. desc
                end

                vim.keymap.set(type, keys, func, { buffer = bufnr, desc = desc })
            end
            local imap = function(keys, func, desc)
                xmap('i', keys, func, desc)
            end
            local nmap = function(keys, func, desc)
                xmap('n', keys, func, desc)
            end

            local function custom_rename()
                local new_name = vim.fn.input('New name: ')
                if new_name ~= nil and new_name ~= '' then
                    vim.lsp.buf.rename(new_name)
                else
                    print("Invalid name, rename canceled.")
                end
            end

            -- nmap('<C-r><C-r>', vim.lsp.buf.rename, '[R]e[n]ame')
            nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            nmap('<leader>rN', custom_rename, '[R]e[n]ame')
            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            nmap('<leader>vca', vim.lsp.buf.code_action, '[V]iew [C]ode [A]ction')
            nmap('<leader>vd', vim.diagnostic.open_float, '[V]iew [D]ialog');
            nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('<leader>gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('<leader>vr', require('telescope.builtin').lsp_references, '[V]iew [R]eferences')
            nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
            nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<M-\\>', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
            nmap('<leader>ps', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[P]roject [S]ymbols')
            nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            nmap('H', vim.lsp.buf.signature_help, 'Signature help')
            nmap('<M-Tab>', vim.lsp.buf.hover, 'Hover Documentation')
            imap('<M-Tab>', vim.lsp.buf.signature_help, 'Signature help');

            local function organize_imports()
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local range = {
                    start = { line = 0, character = 0 },
                    ["end"] = { line = line_count - 1, character = 0 }
                }

                local params = {
                    textDocument = vim.lsp.util.make_text_document_params(),
                    range = range,
                    context = { only = { "source.organizeImports" }, diagnostics = {} }
                }

                local old_apply_edit = vim.lsp.util.apply_workspace_edit
                local restore_apply_edit = false

                local function silent_handler(err, result, ctx, config)
                    return true
                end

                vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function(err, actions, ctx)
                    if err or not actions or #actions == 0 then return end

                    for _, action in ipairs(actions) do
                        if action.kind == "source.organizeImports" or
                            (action.title and action.title:match("Organize Imports")) then
                            vim.lsp.handlers["workspace/executeCommand"] = silent_handler

                            if action.edit then
                                vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
                            elseif action.command then
                                vim.lsp.buf.execute_command(action.command)
                            else
                                local client = vim.lsp.get_client_by_id(ctx.client_id)
                                if client then
                                    client.request("codeAction/resolve", action, function(err, resolved_action)
                                        if err or not resolved_action then return end

                                        if resolved_action.edit then
                                            vim.lsp.util.apply_workspace_edit(resolved_action.edit, "utf-16")
                                        end
                                        if resolved_action.command then
                                            vim.lsp.buf.execute_command(resolved_action.command)
                                        end

                                        vim.lsp.handlers["workspace/executeCommand"] = nil
                                    end, bufnr)
                                    return
                                end
                            end

                            vim.defer_fn(function()
                                vim.lsp.handlers["workspace/executeCommand"] = nil
                            end, 1000)

                            return
                        end
                    end
                end)
            end

            local function format()
                vim.cmd('setlocal expandtab')
                vim.cmd('setlocal shiftwidth=4')
                local before = vim.fn.getline(1, '$')
                vim.lsp.buf.format()
                if vim.bo.filetype == 'java' then
                    require('jdtls').organize_imports()
                else
                    organize_imports()
                end
                local after = vim.fn.getline(1, '$')
                if before ~= after then
                    vim.cmd('update')
                end
            end
            local function format_all_files()
                local current_buffer = vim.fn.bufname('%')
                local current_win_view = vim.fn.winsaveview()
                local project_files = vim.fn.glob('**', true, true)
                for _, filename in ipairs(project_files) do
                    if vim.fn.filereadable(filename) == 1 then
                        vim.cmd('keepalt edit ' .. filename)
                        format()
                    else
                        print("File doesn't exist: " .. filename)
                    end
                end
                if current_buffer ~= '' then
                    vim.cmd('buffer ' .. current_buffer)
                    vim.fn.winrestview(current_win_view)
                end
            end
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                format()
            end, { desc = 'Format current buffer with LSP' })
            nmap('<leader>dF', ':Format<CR>', '[D]ocument [F]ormat')
            vim.api.nvim_buf_create_user_command(bufnr, 'FormatAll', function(_)
                format_all_files()
            end, { desc = 'Format all project files with LSP' })
            nmap('<leader>pF', ':FormatAll<CR>', '[P]roject [F]ormat')

            local function rename_file()
                local current_name = vim.fn.expand('%:t')
                local new_name = vim.fn.input('New file name: ', current_name)

                if new_name == '' then
                    print("No new name provided, aborting.")
                    return
                end

                vim.lsp.buf.rename(new_name)

                local current_path = vim.fn.expand('%:p')
                local new_path = vim.fn.fnamemodify(current_path, ':h') .. '/' .. new_name
                vim.fn.rename(current_path, new_path)

                vim.cmd('e ' .. new_path)
                vim.cmd('bwipeout ' .. current_path)
            end

            vim.api.nvim_buf_create_user_command(bufnr, 'Rename', function(_)
                rename_file()
            end, { desc = 'Rename current file and update lsp_references' });
        end

        return metals_config
    end,
    config = function(self, opts)
        -- use 'opts' if Lazy.nvim is recent enough to support config(self, opts)
        local metals_config = opts or require("metals").bare_config()

        local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = self.ft,
            callback = function()
                require("metals").initialize_or_attach(metals_config)
            end,
            group = nvim_metals_group,
        })
    end
}
