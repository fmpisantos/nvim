return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.5',
	--  tag = '0.1.x'
	dependencies = {
		'nvim-lua/plenary.nvim'
	},
	config = function()
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "[P]roject [F]ile" });
		vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = "[P]roject [G]rep" });
		vim.keymap.set('n', '<leader>dg',function() builtin.live_grep({search_dirs={vim.fn.expand("%:p")}}) end,{ desc = "[D]ocument [G]rep" });
		vim.keymap.set('n', '<leader><leader>', "<cmd>:Telescope keymaps<CR>", { desc = "Grep over keymaps" });
	end
}
