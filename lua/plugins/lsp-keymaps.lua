local M = {}
function M.on_attach(_, bufnr)
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

    nmap('<leader>vd', vim.diagnostic.open_float, '[V]iew [D]ialog');
    nmap('grd', vim.diagnostic.open_float, '[V]iew [D]ialog');
    nmap('<M-\\>', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('H', vim.lsp.buf.signature_help, 'Signature help')
    nmap('<M-Tab>', vim.lsp.buf.hover, 'Hover Documentation')
    imap('<M-Tab>', vim.lsp.buf.signature_help, 'Signature help');
    imap('<C-k>', function() vim.lsp.buf.signature_help() end, 'Signature help');
    imap('<C-K>', function() require('cmp').open_docs() end, 'Open docs')
    -- nmap('<C-K>', function()
    --     vim.print("CMP docs"); require('cmp').open_docs()
    -- end, 'Open docs')

    local function organize_imports(buf)
        -- allow explicit buffer or default to current buffer
        local b = buf or vim.api.nvim_get_current_buf()
        local line_count = vim.api.nvim_buf_line_count(b)
        local range = {
            start = { line = 0, character = 0 },
            ["end"] = { line = line_count - 1, character = 0 }
        }

        local params = {
            textDocument = vim.lsp.util.make_text_document_params(b),
            range = range,
            context = { only = { "source.organizeImports" }, diagnostics = {} }
        }

        local function silent_handler()
            return true
        end

        vim.lsp.buf_request(b, "textDocument/codeAction", params, function(err, actions, ctx)
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
                            client:request("codeAction/resolve", action, function(_err, resolved_action)
                                if _err or not resolved_action then return end

                                if resolved_action.edit then
                                    vim.lsp.util.apply_workspace_edit(resolved_action.edit, "utf-16")
                                end
                                if resolved_action.command then
                                    client:exec_cmd(resolved_action.command)
                                end

                                vim.lsp.handlers["workspace/executeCommand"] = nil
                            end, b)
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

    -- make format available globally so other modules (eg. nokia.lua) can call it
    function _G.format(buf)
        local b = buf or 0
        if b == 0 then b = vim.api.nvim_get_current_buf() end
        local before = vim.api.nvim_buf_get_lines(b, 0, -1, false)

        -- run LSP format for the buffer
        pcall(vim.lsp.buf.format, { bufnr = b })

        local ft = vim.api.nvim_buf_get_option(b, 'filetype')
        if ft == 'java' then
            -- jdtls organize_imports expects current buffer; switch temporarily
            local cur = vim.api.nvim_get_current_buf()
            vim.api.nvim_set_current_buf(b)
            pcall(require, 'jdtls')
            if package.loaded['jdtls'] and type(require('jdtls').organize_imports) == 'function' then
                pcall(require('jdtls').organize_imports)
            end
            vim.api.nvim_set_current_buf(cur)
        else
            vim.api.nvim_buf_set_option(b, 'expandtab', true)
            vim.api.nvim_buf_set_option(b, 'shiftwidth', 4)
            organize_imports(b)
        end

        local after = vim.api.nvim_buf_get_lines(b, 0, -1, false)
        if before ~= after then
            local cur = vim.api.nvim_get_current_buf()
            vim.api.nvim_set_current_buf(b)
            vim.cmd('update')
            vim.api.nvim_set_current_buf(cur)
        end
    end
    local format = _G.format
    local function format_all_files()
        local current_buffer = vim.fn.bufname('%')
        local current_win_view = vim.fn.winsaveview()

        -- Get all non-gitignored files
        local git_files = vim.fn.systemlist('git ls-files --cached --others --exclude-standard')

        for _, filename in ipairs(git_files) do
            if vim.fn.filereadable(filename) == 1 then
                vim.cmd('keepalt edit ' .. vim.fn.fnameescape(filename))
                format()
            else
                print("File doesn't exist: " .. filename)
            end
        end

        if current_buffer ~= '' then
            vim.cmd('buffer ' .. vim.fn.fnameescape(current_buffer))
            vim.fn.winrestview(current_win_view)
        end
    end
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        format()
    end, { desc = 'Format current buffer with LSP' })
    nmap('<leader>dF', ':Format<CR>', '[D]ocument [F]ormat')
    vim.api.nvim_buf_create_user_command(bufnr, 'FormatAll', function(_)
        format_all_files()
    end, { desc = 'Format all project files with LSP' });
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

    local cached_files = nil
    local cached_headers = nil

    local function get_project_headers()
        if not cached_headers then
            cached_headers = vim.fn.systemlist(
                'fd --type f --extension h --extension hpp'
            )
        end
        return cached_headers
    end

    local function get_project_files()
        if not cached_files then
            cached_files = vim.fn.systemlist(
                'fd --type f --extension cpp --extension cc --extension c'
            )
        end
        return cached_files
    end

    local function find_corresponding_file()
        local filename = vim.fn.expand("%:t:r")
        local ext = vim.fn.expand("%:e")

        local header_exts = { "h", "hpp" }
        local source_exts = { "cpp", "cc", "c" }
        local is_header = false

        local targets = {}
        if vim.tbl_contains(header_exts, ext) then
            is_header = true
            for _, e in ipairs(source_exts) do
                table.insert(targets, filename .. "." .. e)
            end
        elseif vim.tbl_contains(source_exts, ext) then
            for _, e in ipairs(header_exts) do
                table.insert(targets, filename .. "." .. e)
            end
        else
            vim.cmd("ClangdSwitchSourceHeader")
            return
        end

        local results = {}
        local all_files
        if is_header then
            all_files = get_project_files()
        else
            all_files = get_project_headers()
        end

        for _, file in ipairs(all_files) do
            for _, target in ipairs(targets) do
                if file:match(target .. "$") then
                    table.insert(results, file)
                end
            end
        end

        if #results == 0 then
            print("No matching file found")
        elseif #results == 1 then
            vim.cmd("edit " .. results[1])
        else
            local fzf = require("fzf-lua")
            fzf.fzf_exec(results, {
                prompt = "Select corresponding file> ",
                actions = {
                    ["default"] = function(selected)
                        vim.cmd("edit " .. selected[1])
                    end
                }
            })
        end
    end

    nmap("<leader>hh", find_corresponding_file, "Find source/header file");
end

return M
