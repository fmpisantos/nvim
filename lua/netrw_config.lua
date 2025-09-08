vim.keymap.set("n", "-", "<cmd>edit %:p:h<CR><cmd>normal! gv<CR>",
    { noremap = true, silent = true, desc = "Netrw with current file highlighted" })
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
-- Make find search recursively
vim.opt.path:append("**")
-- Make it so that I can tab on :find
vim.opt.wildmenu = true
-- Auto-select current file in netrw
vim.api.nvim_create_augroup("netrw_select_current", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "netrw_select_current",
    pattern = "netrw",
    callback = function()
        local current_file = vim.fn.expand('#:t')
        if current_file ~= '' then
            vim.fn.search('\\V\\^' .. vim.fn.escape(current_file, '\\') .. '\\$')
        end
    end,
})

local file_cache = {
    files = {},
    timestamp = 0,
    cache_duration = 5000 -- ms
}

local function get_files(args)
    local now = vim.fn.reltime()
    local now_ms = vim.fn.reltimestr(now) * 1000

    if not file_cache.files or (now_ms - file_cache.timestamp) > file_cache.cache_duration then
        args = args:gsub("\\", "\\\\")
        file_cache.files = vim.fn.systemlist("fd " .. args .. " --max-results 50")
        file_cache.timestamp = now_ms
    end

    return file_cache.files
end

vim.api.nvim_create_user_command("Fd", function(opts)
    local matches = get_files(opts.args)
    if #matches == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
    elseif #matches > 1 then
        vim.ui.select(matches, {
            prompt = "Select file to open:",
            format_item = function(item)
                return vim.fn.fnamemodify(item, ":.")
            end
        }, function(choice)
            if choice then
                vim.cmd("edit " .. vim.fn.fnameescape(choice))
            end
        end)
    else
        vim.notify("No files found matching: " .. opts.args, vim.log.levels.WARN)
    end
end, {
    nargs = 1,
    desc = "Find and open files using fd",
    complete = function(argLead, _, _)
        return get_files(argLead);
    end
});

-- Define a :Find command that searches only git-tracked/untracked (non-ignored) files
if vim.fn.executable("rg") == 1 then
    -- Cache for file list to avoid calling rg multiple times
    local file_cache = {
        files = nil,
        timestamp = 0,
        cache_duration = 5000 -- 5 seconds cache
    }

    -- Convert glob pattern to lua pattern
    local function glob_to_pattern(glob)
        local pattern = glob:lower()
        -- Escape lua magic characters except *
        pattern = pattern:gsub("[%(%)%.%+%-%?%[%]%^%$%%]", "%%%1")
        -- Convert * to lua pattern
        pattern = pattern:gsub("%*", ".*")
        return pattern
    end

    -- Get base rg command with proper git handling
    local function get_rg_base_cmd()
        -- Check if we're in a git repository
        local git_dir = vim.fn.systemlist("git rev-parse --git-dir 2>/dev/null")
        if vim.v.shell_error == 0 and #git_dir > 0 then
            -- In git repo: respect .gitignore
            return "rg --files --hidden"
        else
            -- Not in git repo: use manual exclusions
            return "rg --files --hidden --glob '!.git/*' --glob '!node_modules/*' --glob '!target/*' --glob '!build/*'"
        end
    end

    -- Get files with caching
    local function get_files()
        local now = vim.fn.reltime()
        local now_ms = vim.fn.reltimestr(now) * 1000

        if not file_cache.files or (now_ms - file_cache.timestamp) > file_cache.cache_duration then
            file_cache.files = vim.fn.systemlist(get_rg_base_cmd())
            file_cache.timestamp = now_ms
        end

        return file_cache.files
    end

    vim.api.nvim_create_user_command("Find", function(opts)
        local files = get_files() -- ACTUALLY USE THE CACHED FUNCTION!
        local query = opts.args:lower()
        local has_wildcards = query:find("*")

        local matches = {}

        if has_wildcards then
            -- Use cached files, then filter with glob pattern
            local pattern = glob_to_pattern(query)

            for _, file in ipairs(files) do
                -- Match against the full file path (case insensitive)
                local filepath = file:lower()
                if filepath:match(pattern) then
                    table.insert(matches, file)
                end
            end
        else
            -- For non-wildcard searches, filter files containing the query
            for _, file in ipairs(files) do
                if file:lower():find(query, 1, true) then
                    table.insert(matches, file)
                end
            end
        end

        if #matches == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
        elseif #matches > 1 then
            vim.ui.select(matches, {
                prompt = "Select file to open:",
                format_item = function(item)
                    -- Show relative path for better readability
                    return vim.fn.fnamemodify(item, ":.")
                end
            }, function(choice)
                if choice then
                    vim.cmd("edit " .. vim.fn.fnameescape(choice))
                end
            end)
        else
            vim.notify("No files found matching: " .. opts.args, vim.log.levels.WARN)
        end
    end, {
        nargs = 1,
        desc = "Find and open files using ripgrep (supports wildcards with *)",
        complete = function(_, cmdline, _)
            local files = get_files() -- ACTUALLY USE THE CACHED FUNCTION HERE TOO!

            -- Extract the current argument being completed
            local args = vim.split(cmdline, "%s+")
            local current_arg = args[#args] or ""
            local query = current_arg:lower()

            local matches = {}

            if query == "" then
                -- Show first 20 files if no query
                for i = 1, math.min(20, #files) do
                    table.insert(matches, vim.fn.fnamemodify(files[i], ":."))
                end
            else
                -- Filter files based on current input
                for _, file in ipairs(files) do
                    local basename = vim.fn.fnamemodify(file, ":t"):lower()
                    local relpath = vim.fn.fnamemodify(file, ":."):lower()

                    if basename:find(query, 1, true) or relpath:find(query, 1, true) then
                        table.insert(matches, vim.fn.fnamemodify(file, ":."))
                        if #matches >= 50 then break end -- Limit completions
                    end
                end
            end

            return matches
        end,
    })
else
    if vim.fn.executable("git") == 1 then
        vim.api.nvim_create_user_command("Find", function(opts)
            local files = vim.fn.systemlist("git ls-files --cached --others --exclude-standard")
            local matches = {}
            local query = opts.args
            local has_wildcards = query:find("[*?]")

            if has_wildcards then
                local pattern = glob_to_pattern(query)
                for _, f in ipairs(files) do
                    if f:lower():match(pattern) then
                        table.insert(matches, f)
                    end
                end
            else
                local lower_query = query:lower()
                for _, f in ipairs(files) do
                    if f:lower():find(lower_query, 1, true) then
                        table.insert(matches, f)
                    end
                end
            end
            if #matches == 1 then
                vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
            elseif #matches > 1 then
                vim.ui.select(matches, { prompt = "Multiple matches:" }, function(choice)
                    if choice then
                        vim.cmd("edit " .. vim.fn.fnameescape(choice))
                    end
                end)
            else
                print("No match found")
            end
        end, {
            nargs = 1,
            complete = function(_, line, _)
                local files = vim.fn.systemlist("git ls-files --cached --others --exclude-standard")
                local prefix = line:match("%S+$") or ""
                local lower_prefix = prefix:lower()
                local matches = {}
                for _, f in ipairs(files) do
                    if f:lower():find(lower_prefix, 1, true) then
                        table.insert(matches, f)
                    end
                end
                return matches
            end,
        })
    end
end
