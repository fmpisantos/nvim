return {
    src = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "mfussenegger/nvim-jdtls",
    },
    setup = function()
        local on_attach = require("plugins.lsp-keymaps").on_attach
        require("mason").setup();
        local capabilities = vim.lsp.protocol.make_client_capabilities()

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

        local jdtls_config = require("plugins.java.config")
        local function on_attach_jdtls(client, _bufnr)
            on_attach(client, _bufnr)
            jdtls_config.jdtls_on_attach(client, _bufnr)
        end
        local cmd, path = jdtls_config.jdtls_setup()

        vim.lsp.config('jdtls', {
            cmd = cmd,
            capabilities = capabilities,
            on_attach = on_attach_jdtls,
            init_options = {
                bundles = path.bundles,
            },
        });

        vim.lsp.config('lemminx', {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                xml = {
                    format = {
                        lineWidth = vim.lsp.get_clients()[1] and 0 or nil
                    }
                }
            },
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
                "jdtls",
                "lua_ls",
                "lemminx",
                "vtsls"
            },
            automatic_installation = true,
            automatic_enable = true
        });

        -- vim.lsp.enable({
        --     "omnisharp",
        --     "jdtls",
        --     "lua_ls",
        --     "lemminx",
        --     "vtsls"
        -- });
    end
}
