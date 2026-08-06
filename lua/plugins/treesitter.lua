return {
    src = {
        -- `main` is the maintained, Neovim 0.12+ compatible branch.
        -- (The old `master` branch was archived and is incompatible with 0.12.)
        { src = "nvim-treesitter/nvim-treesitter", version = "main" },
        "nvim-treesitter/nvim-treesitter-context",
    },
    setup = function()
        -- ~/.config/nvim/lua/plugins/treesitter.lua
        -- nvim-treesitter `main` branch (full rewrite of the old API).
        -- Requires: Neovim 0.12+, tree-sitter-cli and a C compiler on PATH.
        vim.cmd [[packadd nvim-treesitter]]

        local ok, ts = pcall(require, "nvim-treesitter")
        if not ok then
            return -- Treesitter failed to load, skip config
        end

        -- Install / keep parsers up to date. Async; a no-op once installed.
        ts.install({
            'c', 'cpp', 'c_sharp', 'lua', 'markdown', 'markdown_inline',
            'xml', 'json', 'java', 'bash', 'yaml', 'vim', 'vimdoc', 'query',
        })

        -- On `main`, features are opt-in per buffer:
        --   * highlighting   -> vim.treesitter.start()
        --   * folding        -> configured globally in lua/set.lua (foldexpr)
        --   * indentation    -> experimental, indentexpr below
        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('ts_start', { clear = true }),
            callback = function(args)
                local buf = args.buf
                local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                if not lang then
                    return
                end
                -- Only enable if a parser is actually available (avoids errors
                -- for filetypes without an installed parser).
                if not pcall(vim.treesitter.start, buf) then
                    return
                end
                -- Experimental treesitter indentation (parity with the old
                -- master `indent = { enable = true }`).
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                -- Keep vim regex highlighting alongside treesitter for markdown
                -- (parity with old `additional_vim_regex_highlighting`).
                if vim.bo[buf].filetype == 'markdown' then
                    vim.bo[buf].syntax = 'on'
                end
            end,
        })
    end
}
