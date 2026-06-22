---@enum Mode
local Mode = {
    _it = "it",
    _local = "local"
}

--- GetProjectMode by file name
--- @return Mode
function _G.GetProjectMode()
    vim.print("GetProjectMode()")
    local filename = vim.fn.expand("%:t")
    local mode = Mode._local;
    if filename:match(".*IT%.java$") then
        mode = Mode._it
    elseif filename:match(".*%.java$") then
    else
        error("Unknown project mode for file: " .. filename)
    end
    vim.print(mode)
    return mode;
end

---Get the profile path for the current project and given mode
---@param mode Mode Indicates the mode which the project should run
---@return string
function _G.GetProfilePath(mode)
    vim.print("GetProfilePath(" .. mode .. ")")
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 then
        local root_dir = clients[1].config.root_dir
        if not root_dir then
            error("LSP client has no root_dir configured")
        end
        vim.print(root_dir .. "/" .. mode)
        return root_dir .. "/" .. mode;
    else
        error("No LSP client attached")
    end
end

---Get the profile path for the current project and current mode (Obtained via file name)
---@return string
function _G.GetProfilePathHere()
    return GetProfilePath(GetProjectMode())
end

---Runs command docker-cleanup 'docker stop $(docker ps -aq) && docker rm $(docker ps -aq)'
---@return string
function _G.DockerCleanup()
    vim.print("cmd: docker stop $(docker ps -aq) && docker rm $(docker ps -aq)")
    return vim.fn.system("docker stop $(docker ps -aq) && docker rm $(docker ps -aq)")
end

---Run docker compose commands for the given folder
---@param folder string Folder where docker-compose commands should run
---@return string
function _G.DockerCompose(folder)
    vim.print("DockerCompose(" .. folder .. ")")
    local _ = DockerCleanup()
    vim.print("cd " .. folder .. " && docker-compose pull && docker-compose up -d && cd -")
    return vim.fn.system("cd " .. folder .. " && docker-compose pull && docker-compose up -d && cd -")
end

---Run docker-compose commands for the current profile folder
---@return string
function _G.DockerComposeHere()
    return DockerCompose(GetProfilePathHere())
end

--- Format Java files that have git changes (staged, unstaged or untracked)
--- Scans the repo for changed files in the current working tree and runs
--- the global `format()` function for each `.java` file found.
---@return nil
function _G.FormatChangedJavaFiles()
    -- ensure we are inside a git repository
    local inside = vim.fn.systemlist('git rev-parse --is-inside-work-tree')
    if not inside or inside[1] ~= 'true' then
        error('Not inside a git repository')
    end

    local current_buffer = vim.fn.bufname('%')
    local current_win_view = vim.fn.winsaveview()

    local function gather(cmd)
        local res = {}
        local out = vim.fn.systemlist(cmd)
        for _, l in ipairs(out) do
            if l and l ~= '' then table.insert(res, l) end
        end
        return res
    end

    -- staged, unstaged and untracked files
    local files = {}
    for _, f in ipairs(gather('git diff --name-only')) do files[f] = true end
    for _, f in ipairs(gather('git diff --cached --name-only')) do files[f] = true end
    for _, f in ipairs(gather('git ls-files --others --exclude-standard')) do files[f] = true end

    for filename, _ in pairs(files) do
        if filename:match('%.java$') then
            if vim.fn.filereadable(filename) == 1 then
                -- open file, format, then continue
                vim.cmd('keepalt edit ' .. vim.fn.fnameescape(filename))
                -- call global format function (accepts optional bufnr)
                pcall(function() _G.format() end)
            else
                print('File not readable: ' .. filename)
            end
        end
    end

    if current_buffer ~= '' then
        vim.cmd('buffer ' .. vim.fn.fnameescape(current_buffer))
        vim.fn.winrestview(current_win_view)
    end
end

-- Create a user command to run the formatter from command-line inside Neovim
pcall(vim.api.nvim_create_user_command, 'FormatChangedJava', function()
    pcall(function() _G.FormatChangedJavaFiles() end)
end, { desc = 'Format Java files with git changes' })
