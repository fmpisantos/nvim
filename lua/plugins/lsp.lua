vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
});

require("mason").setup();

local servers = {
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
	jdtls = {},
	vtsls = {},
}

vim.filetype.add({
	extension = {
		razor = "cs",
	},
})

for server_name, server_config in pairs(servers) do
	if server_name == "jdtls" then
		local jdtls_config = require("plugins.java.config")
		local function _on_attach(client, bufnr)
			on_attach(client, bufnr)
			jdtls_config.jdtls_on_attach(client, bufnr)
		end
		local cmd, path = jdtls_config.jdtls_setup()
		require('lspconfig')[server_name].setup {
			cmd = cmd,
			capabilities = capabilities,
			on_attach = _on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
			init_options = {
				bundles = path.bundles,
			},
		}
	elseif (server_name == "lemminx") then
		require('lspconfig')[server_name].setup {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				xml = {
					format = {
						lineWidth = vim.lsp.get_clients()[1] and 0 or nil -- Ensure it's only set if LSP is active
					}
				}
			},
			filetypes = servers[server_name] and type(servers[server_name].filetypes) == "table" and servers[server_name].filetypes or { "xml" },
		}
	elseif (server_name == "omnisharp") then
		require('lspconfig')[server_name].setup {
			cmd = { "omnisharp", "--languageserver" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = { "cs", "vb", "razor", "cshtml" },
			root_dir = require('lspconfig').util.root_pattern("*.sln", "*.csproj"),
			init_options = {
				RazorSupport = true
			},
		}
	else
		if (server_name == "vtsls") then
			local vtsls_config = require("plugins.jsts.jsts-dap");
			local function _on_attach(client, bufnr)
				on_attach(client, bufnr)
				vtsls_config.setup()
			end
			require('lspconfig')[server_name].setup {
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
	end
end

require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_enable = true,         -- will hook into vim.lsp.config definitions
})

-- Keybinds
vim.keymap.set('n', '<leader>dF', vim.lsp.buf.format);
