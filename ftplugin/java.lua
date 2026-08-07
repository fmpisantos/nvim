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
