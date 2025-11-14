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
