return {
    src = "fmpisantos/repo-specific.nvim",
    setup = function()
        local r = require('repo-specific')
        r.setup {
            match = 'fmpisantos/static-website',
            on_match = function(_, _)
                vim.api.nvim_create_user_command('DeployLambda', function()
                    local path = vim.api.nvim_buf_get_name(0)
                    if path:match('^oil://') then
                        path = path:sub(7)
                    end

                    local lambda_part = path:match('.*/lambda/([^/]+)')
                    if lambda_part then
                        print('Folder name: ' .. lambda_part)
                    else
                        print('Not inside a lambda folder')
                    end
                end, { desc = 'Deploy current lambda function' })
            end
        }
    end
}
