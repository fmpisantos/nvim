function GetProjectMode()
    local filename = vim.fn.expand("%:t")
    if filename:match(".*IT%.java$") then
        return "it"
    elseif filename:match(".*%.java$") then
        return "local"
    else
        error("Unknown project mode for file: " .. filename)
    end
end

function GetProfilePath()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 then
        local root_dir = clients[1].config.root_dir
        if not root_dir then
            error("LSP client has no root_dir configured")
        end
        local mode = GetProjectMode()
        return root_dir .. "/" .. mode;
    else
        error("No LSP client attached")
    end
end

function DockerCleanup()
    vim.fn.system("docker-cleanup")
end

function DockerCompose(folder)
    DockerCleanup()
    vim.fn.system("cd " .. folder .. " && docker-compose pull && docker-compose up -d")
end
