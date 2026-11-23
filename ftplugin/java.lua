-- Gradle build integration for Java buffers.
-- Wires `:make` to the project's gradle wrapper (resolved from the attached
-- jdtls client's root_dir) and parses javac errors/warnings into the quickfix
-- list, so :copen shows compile failures.

local function get_gradle_root()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = 'jdtls' })
    if #clients > 0 then
        return clients[1].config.root_dir
    end
    return nil
end

local function setup_gradle_build()
    local gradle_root = get_gradle_root()
    if not gradle_root then
        return
    end

    local gradlew_path = gradle_root .. '/gradlew'
    if vim.fn.filereadable(gradlew_path) == 0 then
        return
    end

    -- Run gradlew build from the project root, skipping tests.
    vim.opt_local.makeprg = gradlew_path .. ' build -x test'

    -- Parse Gradle/Java compiler diagnostics.
    -- Matches: filepath:line: error: message  /  filepath:line: warning: message
    -- Ignores Gradle task output lines (those starting with ||).
    vim.opt_local.errorformat = '%f:%l: %t%*[a-z]: %m,%-G||%.%#,%-G%.%#'
end

-- jdtls attaches asynchronously, so re-run once the client is up.
vim.api.nvim_create_autocmd('LspAttach', {
    buffer = 0,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'jdtls' then
            setup_gradle_build()
        end
    end,
    once = false,
})

-- Initial setup (covers the case where jdtls is already attached)
setup_gradle_build()

vim.api.nvim_buf_create_user_command(0, 'OpenInIntellij', function()
    local root = get_gradle_root() or vim.fn.getcwd()
    local file_path = vim.fn.expand('%:p')
    local relative_file = file_path:gsub('^' .. vim.pesc(root) .. '/', '')
    vim.uv.spawn('idea', { args = { root, relative_file }, detached = true }, function(code, _)
        if code ~= 0 then
            vim.schedule(function()
                vim.notify('Failed to open IntelliJ: exit code ' .. code, vim.log.levels.ERROR)
            end)
        end
    end)
end, {
    desc = 'Open current project and file in IntelliJ'
})

vim.api.nvim_buf_create_user_command(0, 'JdtlsCleanProject', function()
    local root = get_gradle_root() or vim.fn.getcwd()

    local patterns = { '.classpath', '.project', '.factorypath', '.settings', '.apt_generated' }
    local removed = {}

    -- Walk up to 3 levels deep (root + submodules), skipping node_modules/.git
    local function scan(dir, depth)
        if depth > 3 then return end
        local handle = vim.uv.fs_scandir(dir)
        if not handle then return end
        while true do
            local name, t = vim.uv.fs_scandir_next(handle)
            if not name then break end
            local full = dir .. '/' .. name
            if vim.tbl_contains(patterns, name) then
                vim.fn.delete(full, 'rf')
                table.insert(removed, full)
            elseif t == 'directory' and name ~= 'node_modules' and name ~= '.git' then
                scan(full, depth + 1)
            end
        end
    end
    scan(root, 1)

    -- Wipe jdtls workspace data dir for this project
    local data_dir = vim.fn.stdpath('cache')
        .. '/nvim-jdtls/'
        .. vim.fn.fnamemodify(root, ':p:h:t')
    if vim.fn.isdirectory(data_dir) == 1 then
        vim.fn.delete(data_dir, 'rf')
        table.insert(removed, data_dir)
    end

    if #removed == 0 then
        vim.notify('JdtlsCleanProject: nothing to remove', vim.log.levels.INFO)
    else
        vim.notify('JdtlsCleanProject removed:\n' .. table.concat(removed, '\n'), vim.log.levels.INFO)
        vim.notify('Restart Neovim (or :LspRestart jdtls) to re-import from Gradle.', vim.log.levels.WARN)
    end
end, {
    desc = 'Delete Eclipse metadata (.classpath/.project/.settings/...) and jdtls workspace cache'
})

vim.api.nvim_buf_create_user_command(0, 'MakeClean', function()
    local gradle_root = get_gradle_root()
    if not gradle_root then
        vim.notify('Could not find gradle root from LSP', vim.log.levels.ERROR)
        return
    end

    local gradlew_path = gradle_root .. '/gradlew'
    if vim.fn.filereadable(gradlew_path) == 0 then
        vim.notify('gradlew not found at: ' .. gradlew_path, vim.log.levels.ERROR)
        return
    end

    vim.opt_local.makeprg = gradlew_path .. ' clean build'
    vim.cmd('make')
end, {
    desc = 'Run ./gradlew clean build from project root'
})
