return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            -- { 'j-hui/fidget.nvim',    opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
            {
                -- Autocompletion
                'hrsh7th/nvim-cmp',
                dependencies = {
                    -- Snippet Engine & its associated nvim-cmp source
                    'L3MON4D3/LuaSnip',
                    'saadparwaiz1/cmp_luasnip',

                    -- Adds LSP completion capabilities
                    'hrsh7th/cmp-nvim-lsp',
                    'hrsh7th/cmp-path',

                    -- Adds a number of user-friendly snippets
                    'rafamadriz/friendly-snippets',
                },
            },
            { 'folke/which-key.nvim', opts = {} }
        },
        config = function()
            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
                end

                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>vvv', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                nmap('<leader>vca', vim.lsp.buf.code_action, '[V]iew [C]ode [A]ction')
                nmap('<leader>vd', vim.diagnostic.open_float, '[V]iew [D]ialog');
                nmap('<leader>vs', vim.lsp.buf.signature_help, '[V]iew [S]igniture');
                vim.keymap.set('i', '<leader>k', vim.lsp.buf.signature_help,
                    { buffer = bufnr, desc = '[V]iew [S]igniture' })

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

                local function format()
                    -- Set buffer-local options for formatting
                    vim.cmd('setlocal expandtab')
                    vim.cmd('setlocal shiftwidth=4')

                    -- Get the content of the buffer before formatting
                    local before = vim.fn.getline(1, '$')

                    -- Trigger LSP formatting
                    vim.lsp.buf.format()

                    -- Get the content of the buffer after formatting
                    local after = vim.fn.getline(1, '$')

                    -- Check if there are any differences between before and after formatting
                    if before ~= after then
                        vim.cmd('update') -- Save the buffer if changes were made
                    end
                end
                local function format_all_files()
                    -- Store the current buffer name and window layout
                    local current_buffer = vim.fn.bufname('%')
                    local current_win_view = vim.fn.winsaveview()

                    -- Get a list of all files in the project
                    local project_files = vim.fn.glob('**', true, true)

                    -- Loop through each file
                    for _, filename in ipairs(project_files) do
                        -- Check if the file exists
                        if vim.fn.filereadable(filename) == 1 then
                            -- Open the file without modifying the jump list or window layout
                            vim.cmd('keepalt edit ' .. filename)
                            format()
                        else
                            -- Print a message indicating that the file doesn't exist
                            print("File doesn't exist: " .. filename)
                        end
                    end

                    -- Return to the original buffer and restore window layout
                    if current_buffer ~= '' then
                        vim.cmd('buffer ' .. current_buffer)
                        vim.fn.winrestview(current_win_view)
                    end
                end
                -- Create a command `:Format` local to the LSP buffer
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
                rust_analyzer = {},
                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
                tsserver = {},
                jdtls = {}
            }

            -- Setup neovim lua configuration
            require('neodev').setup()

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'

            mason_lspconfig.setup {
                ensure_installed = vim.tbl_keys(servers),
            }

            mason_lspconfig.setup_handlers {
                function(server_name)
                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                        filetypes = (servers[server_name] or {}).filetypes,
                    }
                end,
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
        end
    }
}
