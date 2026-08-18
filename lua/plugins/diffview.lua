return {
    src = "sindrets/diffview.nvim",
    setup = function()
        -- `--imply-local` makes the right-hand side of the diff use the
        -- working-tree file instead of a `diffview://` virtual buffer, so
        -- LSP servers (jdtls, vtsls, ...) attach normally and you get
        -- diagnostics / hover / go-to-def while reviewing.
        -- The left (base) side stays virtual: LSP cannot attach to arbitrary
        -- historical revisions since they don't exist on disk.
        require('diffview').setup({
            default_args = {
                DiffviewOpen = { "--imply-local" },
            },
        })
    end
}
