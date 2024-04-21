return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            -- { 'j-hui/fidget.nvim',    opts = {} },
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
                    'saadparwaiz1/cmp_luasnip',
                    'hrsh7th/cmp-nvim-lsp',
                    'hrsh7th/cmp-path',
                }
            },
            { 'folke/which-key.nvim', opts = {} }
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
                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>vvv', vim.lsp.buf.rename, '[R]e[n]ame')
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
                imap('<M-k>', vim.lsp.buf.hover, 'Signature help')
                imap('<C-k>', vim.lsp.buf.signature_help, 'Signature help')
                local function format()
                    vim.cmd('setlocal expandtab')
                    vim.cmd('setlocal shiftwidth=4')
                    local before = vim.fn.getline(1, '$')
                    vim.lsp.buf.format()
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
            end
            require('which-key').register {
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>v'] = { name = '[V]iew', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                ['<leader>p'] = { name = '[P]roject', _ = 'which_key_ignore' },
                ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
                ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
                ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
                ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
                ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
            }
            require('which-key').register({
                ['<leader>'] = { name = 'VISUAL <leader>' },
                ['<leader>h'] = { 'Git [H]unk' },
            }, { mode = 'v' })
            require('mason').setup()
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
            mason_lspconfig.setup {
                ensure_installed = vim.tbl_keys(servers),
            }

            local function noop()
                -- This function does nothing (equivalent to `lsp_zero.noop` in the previous example)
            end

            mason_lspconfig.setup_handlers {
                function(server_name)
                    if (server_name == "jdtls") then
                        local jdtls_config = require("awman.plugins.java.config")
                        local function _on_attach(client, bufnr)
                            on_attach(client, bufnr)
                            jdtls_config.jdtls_on_attach(client, bufnr)
                        end
                        local cmd = jdtls_config.jdtls_setup()
                        require('lspconfig')[server_name].setup {
                            cmd = cmd,
                            capabilities = capabilities,
                            on_attach = _on_attach,
                            settings = servers[server_name],
                            filetypes = (servers[server_name] or {}).filetypes,
                        }
                    else
                        require('lspconfig')[server_name].setup {
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = servers[server_name],
                            filetypes = (servers[server_name] or {}).filetypes,
                        }
                    end
                end,
                -- jdtls = noop
            }

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
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<Tab>'] = nil,
                    ['<S-Tab>'] = nil,
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                },
            }
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
