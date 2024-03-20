return {
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    config = function()
        require 'nvim-treesitter.install'.compilers = { "clang" }
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "c", "cpp", "lua", "xml" },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']c'] = '@class.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']C'] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[c'] = '@class.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[C'] = '@class.outer',
                    },
                },
            },
        }
    end
}
