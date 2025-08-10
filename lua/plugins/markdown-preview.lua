return {
    src = {
        {
            src = "iamcco/markdown-preview.nvim",
            event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = "cd app && npm install && git restore ."
        },
    }
}
