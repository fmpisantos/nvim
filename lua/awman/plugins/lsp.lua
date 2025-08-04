return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            -- { 'j-hui/fidget.nvim', opts = {} },
            'folke/neodev.nvim',
            {
                'hrsh7th/nvim-cmp',
                event = 'InsertEnter',
                dependencies = {
                    {
                        'L3MON4D3/LuaSnip',
                        build = (function()
                            if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                                return
                            end
                            return 'make install_jsregexp'
                        end)(),
                        dependencies = {
                        },
                    },
                    'hrsh7th/cmp-nvim-lsp',
                    'hrsh7th/cmp-path',
                }
            },
            {
                'folke/which-key.nvim',
                opts = {
                    show_help = false,
                    notify = true,
                }
            }
        },
        opts = {
        },
        config = function()
            local on_attach = function(_, bufnr)
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
                nmap('<M-Tab>', vim.lsp.buf.hover, 'Hover Documentation')
                imap('<C-h>', vim.lsp.buf.signature_help, 'Signature help');
                vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { noremap = true, silent = true })
                -- imap('<C-h>', vim.lsp.buf.signature_help, 'Signature help');

                -- nmap("<leader>hh", "<cmd>ClangdSwitchSourceHeader<CR>", "switch_source_header")

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

                nmap("<leader>hh", find_corresponding_file, "Find source/header file")

                local function format()
                    vim.cmd('setlocal expandtab')
                    vim.cmd('setlocal shiftwidth=4')
                    local before = vim.fn.getline(1, '$')
                    vim.lsp.buf.format()
                    if vim.bo.filetype == 'java' then
                        require('jdtls').organize_imports()
                    end
                    local after = vim.fn.getline(1, '$')
                    if before ~= after then
                        vim.cmd('update')
                    end
                end
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

            require('which-key').add({
                { '<leader>c', desc = '[C]ode' },
                { '<leader>v', desc = '[V]iew' },
                { '<leader>d', desc = '[D]ocument' },
                { '<leader>p', desc = '[P]roject' },
                { '<leader>g', desc = '[G]it' },
                { '<leader>h', desc = 'Git [H]unk' },
                { '<leader>r', desc = '[R]ename' },
                { '<leader>s', desc = '[S]earch' },
                { '<leader>w', desc = '[W]orkspace' },
            });
            require('which-key').add({
                { '<leader>',  desc = 'VISUAL <leader>' },
                { '<leader>h', desc = 'Git [H]unk' }
            }, { mode = 'v' })

            require("mason").setup({
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            })
            -- require('mason').setup()
            require('mason-lspconfig').setup()
            local servers = {
                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
                jdtls = {},
            }

            require('neodev').setup()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
            local mason_lspconfig = require 'mason-lspconfig'

            -- Register filetypes
            vim.filetype.add({
                extension = {
                    razor = "cs",
                },
            })

            -- Define per-server configs using the new API
            for server_name, server_config in pairs(servers) do
                if server_name == "jdtls" then
                    local jdtls_config = require("awman.plugins.java.config")
                    local function _on_attach(client, bufnr)
                        on_attach(client, bufnr)
                        jdtls_config.jdtls_on_attach(client, bufnr)
                    end
                    local cmd, path = jdtls_config.jdtls_setup()

                    vim.lsp.config(server_name, {
                        cmd = cmd,
                        capabilities = capabilities,
                        on_attach = _on_attach,
                        settings = server_config,
                        filetypes = (server_config or {}).filetypes,
                        init_options = {
                            bundles = path.bundles,
                        },
                    })

                elseif server_name == "lemminx" then
                    vim.lsp.config(server_name, {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            xml = {
                                format = {
                                    lineWidth = vim.lsp.get_clients()[1] and 0 or nil,
                                },
                            },
                        },
                        filetypes = (server_config and type(server_config.filetypes) == "table")
                            and server_config.filetypes
                            or { "xml" },
                    })

                elseif server_name == "omnisharp" then
                    vim.lsp.config(server_name, {
                        cmd = { "omnisharp", "--languageserver" },
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = server_config,
                        filetypes = { "cs", "vb", "razor", "cshtml" },
                        root_dir = require('lspconfig').util.root_pattern("*.sln", "*.csproj"),
                        init_options = {
                            RazorSupport = true,
                        },
                    })

                else
                    vim.lsp.config(server_name, {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = server_config,
                        filetypes = (server_config or {}).filetypes,
                    })
                end
            end

            mason_lspconfig.setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = true, -- will hook into vim.lsp.config definitions
            })

            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            require('luasnip.loaders.from_vscode').lazy_load()
            luasnip.config.setup {}

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = {
                    completeopt = 'menu,menuone,noinsert',
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = nil,
                    ['<Tab>'] = nil,
                    ['<S-Tab>'] = cmp.mapping.complete {},
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                },
            }

            cmp.setup.filetype({ "sql" }, {
                sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                }
            })

            vim.diagnostic.config({
                float = {
                    focusable = true,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end
    }
}
