return {
    src = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-treesitter/nvim-treesitter-context",
    },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    setup = function()
        -- ~/.config/nvim/lua/plugins/treesitter.lua
        -- Load Treesitter if it's in opt/
        vim.cmd [[packadd nvim-treesitter]]

        -- Then require safely
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then
          return  -- Treesitter failed to load, skip config
        end

        configs.setup {
                    ensure_installed = { 'c', 'cpp', 'c_sharp', 'lua', 'markdown', 'xml', 'json', 'java' },
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = { "markdown" },
                    },
                    indent = { enable = true },
                    folds = {
                        enable = true
                    }
        }
    end
    --     require('nvim-treesitter.install').prefer_git = true
    --     require('nvim-treesitter.configs').setup({
    --         ensure_installed = { 'c', 'cpp', 'c_sharp', 'lua', 'markdown', 'xml', 'json', 'java' },
    --         auto_install = true,
    --         highlight = {
    --             enable = true,
    --             additional_vim_regex_highlighting = { "markdown" },
    --         },
    --         indent = { enable = true },
    --         folds = {
    --             enable = true
    --         }
    --     });
    -- end
}
