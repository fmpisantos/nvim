local function create_random_temp_file_vsplit()
    local temp_filepath = os.tmpname()

    vim.cmd('vnew ' .. temp_filepath)
    vim.cmd('w')
    return temp_filepath
end

local name = create_random_temp_file_vsplit()

vim.print("Writing to:", name)

vim.system(
    { "sh", "-c", "opencode run 'say hello'" },
    { cwd = vim.fn.getcwd() },
    function(result)
        vim.schedule(function()
            local output = result.stdout or ""
            if result.stderr and result.stderr ~= "" then
                output = output .. result.stderr
            end

            local file = io.open(name, "w")
            if file then
                file:write(output)
                file:close()
            end

            vim.print("exit code:", result.code)
            vim.cmd('checktime')
        end)
    end
)
