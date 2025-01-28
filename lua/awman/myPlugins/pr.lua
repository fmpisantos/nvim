local M = {}
local Job = require("plenary.job")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values

local function safe_notify(msg, log_level)
    vim.schedule(function() vim.notify(msg, log_level) end)
end

local function fetch_pull_requests(callback)
    Job:new({
        command = "gh",
        args = { "pr", "list", "--search", "review-requested:@me", "--json", "number,title,headRefName,baseRefName,url,body", "--jq", ".[]" },
        on_exit = function(job, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    local raw_output = table.concat(job:result(), "\n")
                    local json_array = "[" .. raw_output:gsub("\n", ",") .. "]"
                    local ok, results = pcall(vim.json.decode, json_array)
                    if ok then
                        callback(results)
                    else
                        safe_notify("Failed to parse PR data", vim.log.levels.ERROR)
                    end
                else
                    safe_notify("Failed to fetch pull requests", vim.log.levels.ERROR)
                end
            end)
        end,
    }):start()
end

local function ReviewPullRequest(pr_number, pr_branch, base_branch)
    local fetch_command = "git fetch origin pull/" .. pr_number .. "/head:" .. pr_branch
    local checkout_command = "git checkout " .. pr_branch
    vim.fn.system(fetch_command)
    vim.fn.system(checkout_command)
    vim.cmd("Gdiff " .. base_branch .. ".." .. pr_branch)
    -- vim.cmd("Gvdiff " .. base_branch .. ".." .. pr_branch)
end

local function inspect_pr_changes(branch)
    Job:new({
        command = "gh",
        args = { "pr", "diff", branch },
        on_exit = function(job, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    local changes = table.concat(job:result(), "\n")
                    local diff_buf = vim.api.nvim_create_buf(false, true) -- create a new buffer
                    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, vim.split(changes, "\n"))
                    vim.api.nvim_buf_set_option(diff_buf, 'buftype', 'nofile')
                    vim.api.nvim_buf_set_option(diff_buf, 'swapfile', false)
                    vim.api.nvim_buf_set_name(diff_buf, "PR Changes: " .. branch)

                    -- Set up a split window to show the diff in a side-by-side view
                    vim.api.nvim_command("vsplit")
                    vim.api.nvim_set_current_buf(diff_buf) -- switch to the diff buffer
                else
                    safe_notify("Failed to fetch PR changes", vim.log.levels.ERROR)
                end
            end)
        end,
    }):start()
end

-- local function inspect_pr_changes(pr_number, base_branch)
--     local fetch_command = "Git fetch origin pull/" .. pr_number .. "/head:pr_" .. pr_number
--     vim.cmd(fetch_command)
--     local checkout_command = "Git checkout pr_" .. pr_number
--     vim.cmd(checkout_command)
--     local diff_command = "Gdiffsplit " .. base_branch
--     vim.cmd(diff_command)
-- end

local function checkout_branch(branch)
    Job:new({
        command = "gh",
        args = { "pr", "checkout", branch },
        on_exit = function(_, return_val)
            if return_val == 0 then
                safe_notify("Checked out PR branch: " .. branch, vim.log.levels.INFO)
            else
                safe_notify("Failed to checkout branch", vim.log.levels.ERROR)
            end
        end,
    }):start()
end

local function add_comment(pr_number, file, line, body)
    local current_file = file ~= "" and file or vim.fn.expand('%:p')

    Job:new({
        command = "gh",
        args = {
            "pr", "comment",
            tostring(pr_number),
            "--body", body,
            "--line", tostring(line),
            "--path", current_file,
        },
        on_exit = function(_, return_val)
            if return_val == 0 then
                safe_notify("Comment added to PR #" .. pr_number, vim.log.levels.INFO)
            else
                safe_notify("Failed to add comment", vim.log.levels.ERROR)
            end
        end,
    }):start()
end

local function approve_pr(pr_number)
    Job:new({
        command = "gh",
        args = { "pr", "review", "--approve", tostring(pr_number) },
        on_exit = function(_, return_val)
            if return_val == 0 then
                safe_notify("Approved PR #" .. pr_number, vim.log.levels.INFO)
            else
                safe_notify("Failed to approve PR", vim.log.levels.ERROR)
            end
        end,
    }):start()
end

M.review_prs = function()
    fetch_pull_requests(function(prs)
        vim.schedule(function()
            local entries = {}
            for _, pr in ipairs(prs) do
                table.insert(entries, {
                    value = pr.number,
                    display = string.format("#%d %s (%s)", pr.number, pr.title, pr.headRefName),
                    ordinal = tostring(pr.number),
                    branch = pr.headRefName,
                    pr_data = pr
                })
            end

            pickers.new({}, {
                prompt_title = "Pull Requests for Review",
                finder = finders.new_table({
                    results = entries,
                    entry_maker = function(entry)
                        return {
                            value = entry.value,
                            display = entry.display,
                            ordinal = entry.ordinal,
                            branch = entry.branch,
                            pr_data = entry.pr_data
                        }
                    end,
                }),
                previewer = previewers.new_buffer_previewer({
                    define_preview = function(self, entry)
                        if not entry then return end

                        local preview_buf = vim.api.nvim_create_buf(false, true)
                        local pr = entry.pr_data
                        local lines = {
                            string.format("PR #%s: %s", entry.value, entry.display),
                            "URL: " .. pr.url,
                            "Branch: " .. pr.headRefName,
                            "",
                            "Description:",
                            pr.body or "No description"
                        }

                        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

                        if self.preview_win then
                            vim.api.nvim_win_set_buf(self.preview_win, preview_buf)
                        end
                    end
                }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        vim.print(vim.inspect(selection))
                        ReviewPullRequest(selection.ordinal, selection.branch, selection.pr_data.baseRefName)
                        -- inspect_pr_changes(selection.ordinal, selection.pr_data.baseRefName)
                        inspect_pr_changes(selection.branch)
                        -- checkout_branch(selection.branch)
                    end)

                    map("i", "<C-c>", function()
                        local selection = action_state.get_selected_entry()
                        vim.ui.input({ prompt = "Enter comment (line:body): " }, function(input)
                            if input then
                                local line, body = unpack(vim.split(input, ":"))
                                add_comment(selection.value, "", tonumber(line) or 1, body or "")
                            end
                        end)
                    end)

                    map("i", "<C-a>", function()
                        local selection = action_state.get_selected_entry()
                        approve_pr(selection.value)
                    end)

                    return true
                end,
            }):find()
        end)
    end)
end

vim.keymap.set("n", "<leader>pr", function()
    M.review_prs()
end, { desc = "List PRs for review" })

return M
