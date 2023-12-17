return {
	'VonHeikemen/lsp-zero.nvim',
	branch = 'v2.x',
	dependencies = {
		-- LSP Support
		{'neovim/nvim-lspconfig'},             -- Required
		{'williamboman/mason.nvim'},           -- Optional
		{'williamboman/mason-lspconfig.nvim'}, -- Optional

		-- Autocompletion
		{'hrsh7th/nvim-cmp'},     -- Required
		{'hrsh7th/cmp-nvim-lsp'}, -- Required
		{'L3MON4D3/LuaSnip'},     -- Required
	},
	config = function()
		local lsp = require("lsp-zero")

		lsp.preset("recommended")

		-- Fix Undefined global 'vim'
		lsp.nvim_workspace()
		local cmp = require('cmp')
		local cmp_select = {behavior = cmp.SelectBehavior.Select}
		local cmp_mappings = lsp.defaults.cmp_mappings({
			['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
			['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
			['<C-y>'] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete(),
		})

		cmp_mappings['<Tab>'] = nil
		cmp_mappings['<S-Tab>'] = nil

		lsp.setup_nvim_cmp({
			mapping = cmp_mappings
		})

		lsp.set_preferences({
			suggest_lsp_servers = false,
			sign_icons = {
				error = 'E',
				warn = 'W',
				hint = 'H',
				info = 'I'
			}
		})

		lsp.on_attach(function(_, bufnr)
			local opts = {buffer = bufnr, remap = false}

            local nmap = function(keys, func, desc)
                if desc then
                    desc = 'LSP: ' .. desc
                end

                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
            end

            nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('<leader>vr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            nmap('<M-\\>', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<leader>\\', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<leader>ps', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[P]roject [S]ymbols')
			opts["desc"] = "[V]iew [D]ialog";
			vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts);
			opts["desc"] = "[V]iew [C]ode [A]ctions";
			vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts);
			opts["desc"] = "[R]e-[N]ame";
			vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts);
			opts["desc"] = "[V]iew [S]igniture";
			vim.keymap.set("i", "<leader>vs", function() vim.lsp.buf.signature_help() end, opts);
		end)

		lsp.setup()

		vim.diagnostic.config({
			virtual_text = true
		})

	end
}
