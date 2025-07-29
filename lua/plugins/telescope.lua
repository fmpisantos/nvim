function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

vim.pack.add({
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
});
require('telescope').setup {
	extensions = {
		['ui-select'] = {
			require('telescope.themes').get_dropdown(),
		},
	},
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require('telescope.builtin')
-- Search Files
vim.keymap.set('n', '<leader>pf', function() builtin.find_files({ hidden = true }) end, { desc = "[P]roject [F]ile" });
vim.keymap.set('v', '<leader>pf',
	function()
		local text = vim.getVisualSelection()
		builtin.find_files({ default_text = text, hidden = true })
	end, { desc = "[P]roject [F]ile" });
-- Grep
-- Project
vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = "[P]roject [G]rep" });
vim.keymap.set('v', '<leader>pg', function()
	local text = vim.getVisualSelection()
	builtin.live_grep({ default_text = text })
end, { desc = "[P]roject [G]rep" });
-- Document
vim.keymap.set('n', '<leader>dg', function() builtin.live_grep({ search_dirs = { vim.fn.expand("%:p") } }) end,
	{ desc = "[D]ocument [G]rep" });
vim.keymap.set('v', '<leader>dg', function()
	local text = vim.getVisualSelection()
	builtin.live_grep({ search_dirs = { vim.fn.expand("%:p") }, default_text = text })
end, { desc = "[D]ocument [G]rep" });
-- Folder
vim.keymap.set('n', '<leader>fg', function() builtin.live_grep({ search_dirs = { vim.fn.expand("%:h") } }) end,
	{ desc = "[F]older [G]rep" });
vim.keymap.set('v', '<leader>fg', function()
	local text = vim.getVisualSelection()
	builtin.live_grep({ search_dirs = { vim.fn.expand("%:h") }, default_text = text })
end, { desc = "[F]older [G]rep" });

-- vim.keymap.set('n', 'L', ':Telescope lsp_definitions<CR>', { desc = "Peek [L]SP definition" });

-- search over the tags of the current buffer attached lsp server
vim.keymap.set('n', '<leader>pt', builtin.lsp_workspace_symbols, { desc = "[P]roject [T]ags" });

vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

vim.keymap.set('n', '<leader><leader>', "<cmd>:Telescope keymaps<CR>", { desc = "Grep over keymaps" });

vim.keymap.set('n', '<leader>?', "<cmd>:Telescope help_tags<CR>", { desc = "Search helper tags" });

vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' });
vim.keymap.set('n', '<M-\\>', require('telescope.builtin').lsp_document_symbols, {desc = '[D]ocument [S]ymbols'})
