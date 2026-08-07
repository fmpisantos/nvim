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
    -- NB: <C-K> and <C-k> normalize to the same mapping, so the completion-docs
    -- popup gets <M-k> rather than clobbering signature help.
    imap('<M-k>', function() require('cmp').open_docs() end, 'Open completion docs')

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

    local function format(buf)
        local b = buf or 0
        if b == 0 then b = vim.api.nvim_get_current_buf() end
        local before = vim.api.nvim_buf_get_lines(b, 0, -1, false)

        local ft = vim.bo[b].filetype
        if ft == 'java' then
            -- jdtls can be slow, especially during batch formatting; give it more time
            pcall(vim.lsp.buf.format, { bufnr = b, timeout_ms = 10000 })

            -- jdtls organize_imports expects the current buffer; switch temporarily
            local cur = vim.api.nvim_get_current_buf()
            vim.api.nvim_set_current_buf(b)
            if pcall(require, 'jdtls') and type(require('jdtls').organize_imports) == 'function' then
                pcall(require('jdtls').organize_imports)
            end
            vim.api.nvim_set_current_buf(cur)
        else
            pcall(vim.lsp.buf.format, { bufnr = b })
            vim.bo[b].expandtab = true
            vim.bo[b].shiftwidth = 4
            organize_imports(b)
        end

        local after = vim.api.nvim_buf_get_lines(b, 0, -1, false)
        if not vim.deep_equal(before, after) then
            local cur = vim.api.nvim_get_current_buf()
            vim.api.nvim_set_current_buf(b)
            vim.b[b].format_in_progress = true
            vim.cmd('update')
            vim.b[b].format_in_progress = false
            vim.api.nvim_set_current_buf(cur)
        end
    end

    local function shellescape_run(cmd)
        local out = vim.fn.systemlist(cmd)
        if vim.v.shell_error ~= 0 then
            return {}
        end
        return out
    end

    -- Deduplicate a list preserving order
    local function dedupe(list)
        local seen = {}
        local result = {}
        for _, v in ipairs(list) do
            if v ~= '' and not seen[v] then
                seen[v] = true
                table.insert(result, v)
            end
        end
        return result
    end

    -- Resolve a git-param into a list of files.
    -- Supported params:
    --   staged                -> files staged
    --   unstaged              -> files modified but not staged, plus untracked non-ignored
    --   commit                -> files staged or unstaged
    --   commit <hash>         -> files changed in the given commit
    --   local                 -> staged + unstaged + commits on this branch not yet pushed
    -- Returns a list of repo-root-relative paths, or nil if the param is unknown.
    local function resolve_git_param(param, extra)
        if not param or param == '' then
            return nil
        end

        local files = {}
        if param == 'staged' then
            files = shellescape_run('git diff --name-only --cached --diff-filter=ACMR')
        elseif param == 'unstaged' then
            local modified = shellescape_run('git diff --name-only --diff-filter=ACMR')
            local untracked = shellescape_run('git ls-files --others --exclude-standard')
            for _, f in ipairs(modified) do table.insert(files, f) end
            for _, f in ipairs(untracked) do table.insert(files, f) end
        elseif param == 'commit' then
            if extra and extra ~= '' then
                files = shellescape_run(
                    'git diff-tree --no-commit-id --name-only -r --diff-filter=ACMR ' ..
                    vim.fn.shellescape(extra)
                )
            else
                local staged = shellescape_run('git diff --name-only --cached --diff-filter=ACMR')
                local modified = shellescape_run('git diff --name-only --diff-filter=ACMR')
                local untracked = shellescape_run('git ls-files --others --exclude-standard')
                for _, f in ipairs(staged) do table.insert(files, f) end
                for _, f in ipairs(modified) do table.insert(files, f) end
                for _, f in ipairs(untracked) do table.insert(files, f) end
            end
        elseif param == 'local' then
            local staged = shellescape_run('git diff --name-only --cached --diff-filter=ACMR')
            local modified = shellescape_run('git diff --name-only --diff-filter=ACMR')
            local untracked = shellescape_run('git ls-files --others --exclude-standard')
            for _, f in ipairs(staged) do table.insert(files, f) end
            for _, f in ipairs(modified) do table.insert(files, f) end
            for _, f in ipairs(untracked) do table.insert(files, f) end

            -- Files changed in commits on this branch not yet pushed upstream.
            local upstream = vim.fn.systemlist(
                'git rev-parse --abbrev-ref --symbolic-full-name @{u}'
            )
            if vim.v.shell_error == 0 and upstream[1] and upstream[1] ~= '' then
                local committed = shellescape_run(
                    'git diff --name-only --diff-filter=ACMR ' ..
                    vim.fn.shellescape(upstream[1] .. '..HEAD')
                )
                for _, f in ipairs(committed) do table.insert(files, f) end
            end
        else
            return nil
        end

        return dedupe(files)
    end

    -- Progress reporter: writes a single-line status to the cmdline area.
    local function make_progress(label)
        local function update(text)
            vim.schedule(function()
                vim.api.nvim_echo({ { label .. ': ' .. text, 'ModeMsg' } }, false, {})
                vim.cmd('redraw')
            end)
        end
        local function done(text)
            vim.schedule(function()
                if text and text ~= '' then
                    vim.api.nvim_echo({ { label .. ': ' .. text, 'MoreMsg' } }, true, {})
                else
                    vim.api.nvim_echo({ { '' } }, false, {})
                end
            end)
        end
        return { update = update, done = done }
    end

    -- Async LSP formatting for a specific buffer.
    -- Sends textDocument/formatting to any client that supports it, applies the
    -- returned edits, then invokes cb(stats) where stats is
    -- { clients = N, formatters = N, applied = N, errors = N }.
    local function lsp_format_async(buf, cb)
        local clients = vim.lsp.get_clients({ bufnr = buf })
        local formatters = {}
        for _, c in ipairs(clients) do
            local supports = false
            -- Prefer client:supports_method (handles dynamic registration,
            -- which jdtls uses for textDocument/formatting).
            if type(c.supports_method) == 'function' then
                local ok, s = pcall(function()
                    return c:supports_method('textDocument/formatting', { bufnr = buf })
                end)
                if not ok then
                    -- fallback to non-colon call signature for older nvim
                    ok, s = pcall(c.supports_method, 'textDocument/formatting', { bufnr = buf })
                end
                if ok then supports = s and true or false end
            end
            if not supports and c.server_capabilities
                and c.server_capabilities.documentFormattingProvider then
                supports = true
            end
            if supports then
                table.insert(formatters, c)
            end
        end
        local stats = { clients = #clients, formatters = #formatters, applied = 0, errors = 0 }
        if #formatters == 0 then
            return cb(stats)
        end

        local sw = vim.bo[buf].shiftwidth
        if sw == 0 then sw = vim.bo[buf].tabstop end
        local params = {
            textDocument = vim.lsp.util.make_text_document_params(buf),
            options = {
                tabSize = sw,
                insertSpaces = vim.bo[buf].expandtab,
                trimTrailingWhitespace = true,
                insertFinalNewline = true,
                trimFinalNewlines = true,
            },
        }

        local remaining = #formatters
        local function one_done()
            remaining = remaining - 1
            if remaining <= 0 then cb(stats) end
        end

        for _, client in ipairs(formatters) do
            local ok, req_id = pcall(function()
                return client:request('textDocument/formatting', params, function(err, result)
                    if err then
                        stats.errors = stats.errors + 1
                    elseif result and vim.api.nvim_buf_is_loaded(buf) then
                        local enc = client.offset_encoding or 'utf-16'
                        local ok2 = pcall(vim.lsp.util.apply_text_edits, result, buf, enc)
                        if ok2 then
                            stats.applied = stats.applied + #result
                        else
                            stats.errors = stats.errors + 1
                        end
                    end
                    one_done()
                end, buf)
            end)
            if not ok or not req_id then
                stats.errors = stats.errors + 1
                one_done()
            end
        end
    end

    -- Async organize-imports via the source.organizeImports code action.
    local function organize_imports_async(buf, cb)
        if not vim.api.nvim_buf_is_loaded(buf) then return cb() end
        local line_count = vim.api.nvim_buf_line_count(buf)
        local params = {
            textDocument = vim.lsp.util.make_text_document_params(buf),
            range = {
                start = { line = 0, character = 0 },
                ["end"] = { line = math.max(0, line_count - 1), character = 0 },
            },
            context = { only = { "source.organizeImports" }, diagnostics = {} },
        }

        vim.lsp.buf_request(buf, 'textDocument/codeAction', params, function(err, actions, ctx)
            if err or not actions or #actions == 0 then return cb() end
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            if not client then return cb() end

            local function apply_action(action, done)
                if action.edit then
                    pcall(vim.lsp.util.apply_workspace_edit, action.edit,
                        client.offset_encoding or 'utf-16')
                end
                if action.command then
                    pcall(function() client:exec_cmd(action.command) end)
                end
                done()
            end

            for _, action in ipairs(actions) do
                if action.kind == 'source.organizeImports'
                    or (action.title and action.title:match('Organize Imports')) then
                    if action.edit or action.command then
                        return apply_action(action, cb)
                    end
                    local ok = pcall(function()
                        client:request('codeAction/resolve', action, function(_err, resolved)
                            if _err or not resolved then return cb() end
                            apply_action(resolved, cb)
                        end, buf)
                    end)
                    if not ok then return cb() end
                    return
                end
            end
            cb()
        end)
    end

    -- Async format of a single buffer (formatting + organize imports).
    -- Calls cb(stats) when finished. The buffer must be loaded.
    local function format_buffer_async(buf, cb)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
            return cb({ clients = 0, formatters = 0, applied = 0, errors = 0 })
        end
        local ft = vim.bo[buf].filetype

        lsp_format_async(buf, function(stats)
            organize_imports_async(buf, function()
                if ft ~= 'java' then
                    pcall(function()
                        vim.bo[buf].expandtab = true
                        vim.bo[buf].shiftwidth = 4
                    end)
                end
                cb(stats)
            end)
        end)
    end

    -- Wait (non-blocking) for at least one LSP client to attach to `buf`.
    -- If `client_name` is given, wait for that specific server. Calls cb(ok).
    local function wait_for_lsp(buf, client_name, timeout_ms, cb)
        local start = vim.uv.now()
        local function check()
            if not vim.api.nvim_buf_is_valid(buf) then return cb(false) end
            local clients = vim.lsp.get_clients({ bufnr = buf })
            for _, c in ipairs(clients) do
                if (not client_name or c.name == client_name) and c.initialized then
                    return cb(true)
                end
            end
            if vim.uv.now() - start > timeout_ms then return cb(false) end
            vim.defer_fn(check, 100)
        end
        check()
    end

    -- filetype_filter: optional filetype string (e.g. 'java')
    -- git_param, git_extra: optional git-param and (for 'commit') its hash
    -- cmd_label: label used for progress messages (e.g. 'FormatAllType java')
    local function format_all_files(filetype_filter, git_param, git_extra, cmd_label)
        local files
        if git_param and git_param ~= '' then
            files = resolve_git_param(git_param, git_extra)
            if files == nil then
                vim.notify('Unknown git-param: ' .. git_param, vim.log.levels.ERROR)
                return
            end
        else
            files = vim.fn.systemlist('git ls-files --cached --others --exclude-standard')
        end

        -- Pre-filter by filetype so progress totals reflect actual work.
        local targets = {}
        for _, filename in ipairs(files) do
            if vim.fn.filereadable(filename) == 1 then
                if filetype_filter and filetype_filter ~= '' then
                    local ft_guess = vim.filetype.match({ filename = filename }) or ''
                    if ft_guess == filetype_filter then
                        table.insert(targets, filename)
                    end
                else
                    table.insert(targets, filename)
                end
            end
        end

        local total = #targets
        local progress = make_progress(cmd_label or 'FormatAll')
        if total == 0 then
            progress.done('no files to format')
            return
        end

        local index = 0
        local jdtls_ready = false
        local summary = {
            processed = 0,
            no_client = 0,
            no_formatter = 0,
            errors = 0,
            skipped_lsp_timeout = 0,
            written = 0,
        }

        local function finalize()
            local parts = {
                string.format('done %d/%d', summary.processed, total),
            }
            if summary.written > 0 then
                table.insert(parts, string.format('wrote %d', summary.written))
            end
            if summary.no_client > 0 then
                table.insert(parts, string.format('no-lsp %d', summary.no_client))
            end
            if summary.no_formatter > 0 then
                table.insert(parts, string.format('no-formatter %d', summary.no_formatter))
            end
            if summary.errors > 0 then
                table.insert(parts, string.format('errors %d', summary.errors))
            end
            if summary.skipped_lsp_timeout > 0 then
                table.insert(parts,
                    string.format('skipped-timeout %d', summary.skipped_lsp_timeout))
            end
            progress.done(table.concat(parts, ', '))
        end

        local function process_next()
            index = index + 1
            if index > total then
                finalize()
                return
            end

            local filename = targets[index]
            progress.update(string.format('[%d/%d]: %s', index, total, filename))

            local abs = vim.fn.fnamemodify(filename, ':p')
            local existing_bufnr = vim.fn.bufnr(abs)
            local was_loaded = existing_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(existing_bufnr)

            local buf = vim.fn.bufadd(abs)
            if buf == 0 then
                vim.schedule(process_next)
                return
            end
            -- Mark the buffer as batch-formatted *before* bufload fires
            -- BufReadPost/FileType/LspAttach, so hooks (codelens refresh,
            -- save-hooks, etc.) can bail out for these ephemeral loads.
            vim.b[buf].format_in_progress = true
            -- Run bufload (and the autocmds it triggers) with this buffer as
            -- current. Some LSP setups (notably jdtls' FileType hook) call APIs
            -- that read the *current* buffer, so a hidden load would otherwise
            -- fail to attach a client.
            local ok_load = pcall(function()
                if not vim.api.nvim_buf_is_loaded(buf) then
                    vim.api.nvim_buf_call(buf, function()
                        vim.fn.bufload(buf)
                    end)
                end
            end)
            if not ok_load or not vim.api.nvim_buf_is_valid(buf) then
                vim.schedule(process_next)
                return
            end

            local ft = vim.bo[buf].filetype
            -- If filetype wasn't detected during load, force it.
            if ft == '' then
                pcall(function()
                    vim.api.nvim_buf_call(buf, function()
                        vim.cmd('filetype detect')
                    end)
                end)
                ft = vim.bo[buf].filetype
            end

            local function do_format()
                format_buffer_async(buf, function(stats)
                    summary.processed = summary.processed + 1
                    if stats then
                        if stats.clients == 0 then
                            summary.no_client = summary.no_client + 1
                        elseif stats.formatters == 0 then
                            summary.no_formatter = summary.no_formatter + 1
                        end
                        if stats.errors > 0 then
                            summary.errors = summary.errors + stats.errors
                        end
                    end

                    if vim.api.nvim_buf_is_valid(buf) then
                        local modified = vim.bo[buf].modified
                        -- format_in_progress was set at bufadd time; keep it set
                        -- through save so any BufWrite* hooks bail out.
                        pcall(function()
                            vim.api.nvim_buf_call(buf, function()
                                vim.cmd('silent noautocmd keepalt update')
                            end)
                        end)
                        if modified then summary.written = summary.written + 1 end

                        if not was_loaded then
                            local displayed = false
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                if vim.api.nvim_win_get_buf(win) == buf then
                                    displayed = true
                                    break
                                end
                            end
                            if not displayed then
                                -- Defer deletion so pending debounced callbacks
                                -- (e.g. vim.lsp.codelens.refresh, scheduled with
                                -- a delay from on_lines) can complete against a
                                -- still-valid buffer id.
                                local to_delete = buf
                                vim.defer_fn(function()
                                    if vim.api.nvim_buf_is_valid(to_delete) then
                                        local still_displayed = false
                                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                                            if vim.api.nvim_win_get_buf(win) == to_delete then
                                                still_displayed = true
                                                break
                                            end
                                        end
                                        if not still_displayed then
                                            pcall(vim.api.nvim_buf_delete, to_delete,
                                                { force = false, unload = false })
                                        end
                                    end
                                end, 500)
                            else
                                vim.b[buf].format_in_progress = false
                            end
                        else
                            vim.b[buf].format_in_progress = false
                        end
                    end
                    vim.schedule(process_next)
                end)
            end

            if ft == 'java' then
                local timeout_ms = jdtls_ready and 5000 or 60000
                wait_for_lsp(buf, 'jdtls', timeout_ms, function(ok)
                    if not ok then
                        summary.skipped_lsp_timeout = summary.skipped_lsp_timeout + 1
                        vim.notify(
                            'jdtls not ready for ' .. filename .. ', skipping',
                            vim.log.levels.WARN
                        )
                        vim.schedule(process_next)
                        return
                    end
                    jdtls_ready = true
                    do_format()
                end)
            else
                -- Give non-jdtls servers a brief moment to attach; proceed regardless.
                wait_for_lsp(buf, nil, 3000, function(_ok)
                    do_format()
                end)
            end
        end

        progress.update(string.format('[0/%d] starting…', total))
        vim.schedule(process_next)
    end

    local git_param_completions = { 'staged', 'unstaged', 'commit', 'local' }

    --- Parse fargs into { git_param, git_extra }. Returns nil if no git args.
    local function parse_git_args(args)
        if not args or #args == 0 then return nil, nil end
        return args[1], args[2]
    end

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        format()
    end, { desc = 'Format current buffer with LSP' })
    nmap('<leader>dF', ':Format<CR>', '[D]ocument [F]ormat')

    vim.api.nvim_buf_create_user_command(bufnr, 'FormatAll', function(opts)
        local git_param, git_extra = parse_git_args(opts.fargs)
        local label = 'FormatAll'
        if git_param and git_param ~= '' then
            label = label .. ' ' .. git_param
            if git_extra and git_extra ~= '' then label = label .. ' ' .. git_extra end
        end
        format_all_files(nil, git_param, git_extra, label)
    end, {
        desc = 'Format project files with LSP (optionally filtered by git-param)',
        nargs = '*',
        complete = function(_, line)
            local parts = vim.split(line, '%s+')
            if #parts <= 2 then
                return git_param_completions
            end
            return {}
        end,
    });
    nmap('<leader>pF', ':FormatAll<CR>', '[P]roject [F]ormat')

    vim.api.nvim_buf_create_user_command(bufnr, 'FormatAllType', function(opts)
        local args = opts.fargs
        if #args < 1 then
            vim.notify('Usage: :FormatAllType <filetype> [<git-param> [<commit-hash>]]',
                vim.log.levels.ERROR)
            return
        end
        local ft = args[1]
        local git_param = args[2]
        local git_extra = args[3]
        local label = 'FormatAllType ' .. ft
        if git_param and git_param ~= '' then
            label = label .. ' ' .. git_param
            if git_extra and git_extra ~= '' then label = label .. ' ' .. git_extra end
        end
        format_all_files(ft, git_param, git_extra, label)
    end, {
        desc = 'Format project files of a given filetype (optionally filtered by git-param)',
        nargs = '+',
        complete = function(_, line)
            local parts = vim.split(line, '%s+')
            -- parts[1] is the command itself
            if #parts == 2 then
                return { 'java', 'lua', 'python', 'cpp', 'c', 'typescript', 'javascript', 'go', 'rust' }
            elseif #parts == 3 then
                return git_param_completions
            end
            return {}
        end,
    });

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
