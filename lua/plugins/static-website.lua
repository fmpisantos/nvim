return {
    src = "fmpisantos/repo-specific.nvim",
    setup = function()
        local r = require('repo-specific')
        r.setup {
            match = 'fmpisantos/static-websites',
            on_match = function(_, _)
                vim.api.nvim_create_user_command('DeployLambda', function()
                    local path = vim.api.nvim_buf_get_name(0)
                    if path:match('^oil://') then
                        path = path:sub(7)
                    end

                    local lambda_part = path:match('.*/lambda/([^/]+)')
                    if lambda_part then
                        local script = vim.fn.expand('~/Projects/static-websites/scripts/deploy-lambda.sh')
                        if vim.fn.executable(script) == 0 then
                            print('Deploy script not found or not executable: ' .. script)
                            return
                        end

                        -- Run the deploy script asynchronously and forward output to Neovim
                        vim.fn.jobstart({ script, lambda_part }, {
                            on_stdout = function(_, data, _)
                                if data then
                                    for _, line in ipairs(data) do
                                        if line ~= '' then
                                            print(line)
                                        end
                                    end
                                end
                            end,
                            on_stderr = function(_, data, _)
                                if data then
                                    for _, line in ipairs(data) do
                                        if line ~= '' then
                                            vim.notify(line, vim.log.levels.ERROR)
                                        end
                                    end
                                end
                            end,
                            on_exit = function(_, code, _)
                                if code == 0 then
                                    vim.notify('Deploy finished: ' .. lambda_part)
                                else
                                    vim.notify('Deploy failed: ' .. lambda_part .. ' (exit ' .. tostring(code) .. ')', vim.log.levels.ERROR)
                                end
                            end,
                        })
                    else
                        print('Not inside a lambda folder')
                    end
                end, { desc = 'Deploy current lambda function' })
            end
        }
    end
}
