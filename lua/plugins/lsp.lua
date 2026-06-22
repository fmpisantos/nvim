return {
    src = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "mfussenegger/nvim-jdtls",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
    },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    setup = function()
        local on_attach = require("plugins.lsp-keymaps").on_attach
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        require("mason").setup({
            registries = {
                'github:fmpisantos/mason-registry',
                'github:mason-org/mason-registry'
            }
        });

        vim.cmd("MasonUpdate")

        -- Configure nvim-cmp
        local cmp = require("cmp")
        local luasnip = require("luasnip")

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

        -- Your existing LSP configurations follow
        vim.lsp.config('*', {
            capabilities = capabilities,
            on_attach = on_attach,
        })

        vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        })

        -- Use the nvim-jdtls helper to start or attach the server.  jdtls
        -- performs extra initialization (workspace handling, bundles,
        -- debugger integration) that a plain lsp start doesn't provide.
        local jdtls_config = require("plugins.java.config")
        local function on_attach_jdtls(client, _bufnr)
            on_attach(client, _bufnr)
            jdtls_config.jdtls_on_attach(client, _bufnr)
        end

        local cmd, path = jdtls_config.jdtls_setup()

        -- determine root_dir with lspconfig util (works reliably per-file)
        local util = require('lspconfig.util')
        local root_dir = util.root_pattern('.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle')(vim.fn.expand('%:p'))
            or util.find_git_ancestor(vim.fn.getcwd())
            or vim.fn.getcwd()

        local ok_jdtls, jdtls = pcall(require, 'jdtls')
        if ok_jdtls then
            jdtls.start_or_attach({
                cmd = cmd,
                root_dir = root_dir,
                capabilities = capabilities,
                on_attach = on_attach_jdtls,
                settings = {
                    java = {
                        configuration = {
                            runtimes = path.runtimes
                        },
                        test = {
                            config = {
                                {
                                    name = "JUnit 4",
                                    testKind = "junit",
                                    workingDirectory = "${workspaceFolder}",
                                    classPaths = { "$Auto" },
                                    modulePaths = { "$Auto" }
                                }
                            },
                            defaultConfig = "JUnit 4"
                        },
                        format = {
                            enabled = true,
                            settings = {
                                url = path.formatterUrl,
                                profile = "4LabsStyle"
                            }
                        }
                    }
                },
                init_options = {
                    bundles = path.bundles,
                },
            })
        else
            vim.notify("jdtls plugin not available; cannot start jdtls properly", vim.log.levels.WARN)
        end

        vim.lsp.config("clangd", {
            on_attach = on_attach,
            capabilities = capabilities,
            root_markers = { "*.sln", "*.csproj" },
        });

        vim.lsp.config("omnisharp", {
            cmd = { "omnisharp", "--languageserver" },
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "cs", "vb", "razor", "cshtml" },
            root_markers = { "*.sln", "*.csproj" },
            init_options = {
                RazorSupport = true
            },
        });

        local vtsls_config = require("plugins.jsts.jsts-dap")
        local function on_attach_vtsls(client, _bufnr)
            on_attach(client, _bufnr)
            vtsls_config.setup()
        end
        vim.lsp.config("vtsls", {
            capabilities = capabilities,
            on_attach = on_attach_vtsls,
        });

        vim.diagnostic.config({
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "omnisharp",
                -- "jdtls",
                "lua_ls",
                "vtsls"
            },
            automatic_installation = true,
            automatic_enable = true
        });

        -- jdtls is started via require('jdtls').start_or_attach; avoid enabling
        -- it globally with vim.lsp.enable to prevent duplicate or partial clients.

        -- LSP Cache Cleanup function
        function _G.LspCacheCleanup()
            local cache_path = vim.fn.expand("~/snap/alacritty/common/.cache/nvim/nvim-jdtls")
            local result = vim.fn.system("rm -rf " .. vim.fn.shellescape(cache_path))
            if vim.v.shell_error == 0 then
                vim.notify("LSP cache cleaned up successfully: " .. cache_path, vim.log.levels.INFO)
                vim.cmd("LspRestart")
            else
                vim.notify("Failed to cleanup LSP cache at: " .. cache_path, vim.log.levels.ERROR)
            end
        end

        -- Create the :LspCleanup command
        vim.api.nvim_create_user_command("LspCleanup", function()
            _G.LspCacheCleanup()
        end, {
            desc = "Cleanup LSP cache"
        })
    end
}
