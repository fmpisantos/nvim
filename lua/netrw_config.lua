vim.keymap.set("n", "-", "<cmd>edit %:p:h<CR><cmd>normal! gv<CR>", { noremap = true, silent = true, desc = "Netrw with current file highlighted" })
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
-- Make find search recursively
vim.opt.path:append("**")
-- Make it so that I can tab on :find
vim.opt.wildmenu = true

-- Helper function to convert glob pattern to Lua pattern
local function glob_to_pattern(glob)
    local pattern = glob:gsub("([%^%$%(%)%%%.%[%]%+%-%?])", "%%%1") -- escape special chars
    pattern = pattern:gsub("%*", ".-")                              -- * becomes .-
    pattern = pattern:gsub("%?", ".")                               -- ? becomes .
    return pattern:lower()
end

-- Define a :Find command that searches only git-tracked/untracked (non-ignored) files
if vim.fn.executable("rg") == 1 then
    vim.api.nvim_create_user_command("Find", function(opts)
        local files = vim.fn.systemlist("rg -i --files --hidden --glob '!.git/*'")
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
            local files = vim.fn.systemlist("rg -i --files --hidden --glob '!.git/*'")
            local prefix = line:match("%S+$") or ""
            local matches = {}
            local lower_prefix = prefix:lower()
            for _, f in ipairs(files) do
                if f:lower():find(lower_prefix, 1, true) then
                    table.insert(matches, f)
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
