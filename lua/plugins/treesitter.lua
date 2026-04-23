return {
    src = {
        { src = "nvim-treesitter/nvim-treesitter", version = "main" },
        "nvim-treesitter/nvim-treesitter-context",
    },
    setup = function()
        local ts = require('nvim-treesitter')
        if not ts.install then
            vim.notify("nvim-treesitter is on the legacy branch; run :PackUpdate to switch to 'main'",
                vim.log.levels.WARN)
            return
        end

        ts.setup({
            install_dir = vim.fn.stdpath('data') .. '/site',
        })

        ts.install({
            'c', 'cpp', 'c_sharp', 'lua', 'markdown', 'markdown_inline',
            'xml', 'json', 'java',
        })

        vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
                local ok = pcall(vim.treesitter.start, args.buf)
                if ok then
                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'markdown',
            callback = function()
                vim.bo.syntax = 'ON'
            end,
        })
    end,
}
