vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
-- Make find search recursively
vim.opt.path:append("**")
-- Make it so that I can tab on :find
vim.opt.wildmenu = true

-- Define a :Find command that searches only git-tracked/untracked (non-ignored) files
if vim.fn.executable("rg") == 1 then
    vim.api.nvim_create_user_command("Find", function(opts)
        local files = vim.fn.systemlist("rg -i --vimgrep --files --hidden --glob '!*.git/*' --glob ")
        local matches = {}

        local query = opts.args:lower()
        for _, f in ipairs(files) do
            if f:lower():find(query, 1, true) then
                table.insert(matches, f)
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
            local files = vim.fn.systemlist("rg -i --vimgrep --files --hidden --glob '!*.git/*' --glob ")
            local prefix = line:match("%S+$") or ""
            local matches = {}
            local lower_prefix = prefix:lower()
            for _, f in ipairs(files) do
                local fname = f:match("([^/\\]+)$")
                if fname and fname:lower():find(lower_prefix, 1, true) then
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
            local query = opts.args:lower()
            for _, f in ipairs(files) do
                if f:lower():find(query, 1, true) then
                    table.insert(matches, f)
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
                    if f:lower():find(lower_prefix, 1, true) == 1 then
                        table.insert(matches, f)
                    end
                end
                return matches
            end,
        })
    end
end
