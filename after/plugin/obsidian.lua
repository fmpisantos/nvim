require('obsidian').setup({
    -- Required, the path to your vault directory.
    dir = "/Users/fmpi.santos/Projects/NeuralNetwork",

    -- Optional, set the log level for obsidian.nvim.
    log_level = vim.log.levels.DEBUG,

    -- Optional, completion.
    completion = {
        -- If using nvim-cmp, otherwise set to false
        nvim_cmp = true,
        -- Trigger completion at 2 chars
        min_chars = 2,
        -- Where to put new notes created from completion.
        new_notes_location = "current_dir",
        -- Whether to add the output of the note_id_func to new notes in autocompletion.
        prepend_note_id = true
    },

    -- Optional, key mappings.
    mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gd"] = require("obsidian.mapping").gf_passthrough(),
        ["gf"] = require("obsidian.mapping").gf_passthrough(),
    },

    -- Optional, customize how names/IDs for new notes are created.
    note_id_func = function(title)
        -- Your note_id_func remains unchanged.
    end,

    -- Optional, set to true if you don't want obsidian.nvim to manage frontmatter.
    disable_frontmatter = false,

    -- Optional, alternatively you can customize the frontmatter data.
    note_frontmatter_func = function(note)
        -- Your note_frontmatter_func remains unchanged.
    end,
    --
    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external URL.
    follow_url_func = function(url)
        -- Your follow_url_func remains unchanged.
    end,

    -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
    open_app_foreground = true,

    -- Optional, by default commands like `:ObsidianSearch` will attempt to use telescope.nvim.
    finder = "telescope.nvim",

    -- Optional, determines whether to open notes in a horizontal split, a vertical split, or replacing the current buffer (default).
    open_notes_in = "current"
})
