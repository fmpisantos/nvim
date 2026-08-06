local function find_checkstyle_config()
    local util = require('lspconfig.util')
    local root = util.root_pattern('.git', 'settings.gradle', 'pom.xml')(vim.fn.expand('%:p'))
        or vim.fn.getcwd()

    local candidates = {
        root .. '/common/config/checkstyle/checkstyle.xml',
        root .. '/config/checkstyle/checkstyle.xml',
        root .. '/checkstyle.xml',
    }
    for _, p in ipairs(candidates) do
        if vim.fn.filereadable(p) == 1 then
            return p
        end
    end
    return nil
end

local function properties_file_for(cfg)
    local dir = vim.fn.fnamemodify(cfg, ':h')
    local props = vim.fn.stdpath('cache') .. '/checkstyle-' .. vim.fn.sha256(dir) .. '.properties'
    local f = io.open(props, 'w')
    if f then
        f:write('config_loc=' .. dir .. '\n')
        f:write('checkstyle.suppressions.file=' .. dir .. '/suppressions.xml\n')
        f:close()
        return props
    end
    return nil
end

local function init()
    local ok, lint = pcall(require, 'lint')
    if not ok then
        vim.notify('nvim-lint not available', vim.log.levels.WARN)
        return
    end

    local checkstyle_bin = vim.fn.expand('$MASON/bin/checkstyle')

    -- checkstyle plain format: "[LEVEL] <filepath>:<line>[:<col>]: <message> [<Rule>]"
    local pattern = '^%[(%u+)%]%s+(.-):(%d+):(%d*):? (.*) %[([^%]]+)%]%s*$'
    local severity_map = {
        ERROR = vim.diagnostic.severity.ERROR,
        WARN = vim.diagnostic.severity.WARN,
        WARNING = vim.diagnostic.severity.WARN,
        INFO = vim.diagnostic.severity.INFO,
    }

    lint.linters.checkstyle = {
        cmd = checkstyle_bin,
        stdin = false,
        append_fname = true,
        -- Populated by run_checkstyle() below just before invoking try_lint,
        -- because nvim-lint requires `args` to be a list, not a function.
        args = { '-f', 'plain' },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = function(output, bufnr)
            local diagnostics = {}
            if not output or output == '' then return diagnostics end

            for line in vim.gsplit(output, '\n', { plain = true }) do
                local level, _, lnum, col, msg, rule = line:match(pattern)
                if lnum and msg then
                    local l = tonumber(lnum) - 1
                    local c = (col ~= '' and tonumber(col)) and (tonumber(col) - 1) or 0
                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = l,
                        col = c,
                        end_lnum = l,
                        end_col = c + 1,
                        severity = severity_map[level and level:upper() or 'WARN'] or vim.diagnostic.severity.WARN,
                        source = 'checkstyle',
                        message = msg,
                        code = rule,
                    })
                end
            end
            return diagnostics
        end,
    }

    lint.linters_by_ft = lint.linters_by_ft or {}
    lint.linters_by_ft.java = { 'checkstyle' }

    -- Rebuild `args` from the current buffer's project context, then invoke
    -- try_lint. nvim-lint requires `args` to be a list (not a function), so
    -- we mutate it right before each lint pass.
    local function run_checkstyle()
        local a = { '-f', 'plain' }
        local cfg = find_checkstyle_config()
        if cfg then
            table.insert(a, '-c')
            table.insert(a, cfg)
            local props = properties_file_for(cfg)
            if props then
                table.insert(a, '-p')
                table.insert(a, props)
            end
        end
        lint.linters.checkstyle.args = a
        require('lint').try_lint('checkstyle')
    end

    local warned_missing = false
    local grp = vim.api.nvim_create_augroup('nvim_lint_checkstyle', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
        group = grp,
        pattern = '*.java',
        callback = function(args)
            -- Skip while a batch formatter (e.g. :FormatAllType) is driving
            -- this buffer; otherwise every temp-loaded buffer would spam a
            -- lint run and potentially a "not installed" warning.
            if vim.b[args.buf] and vim.b[args.buf].format_in_progress then
                return
            end
            if vim.fn.executable(checkstyle_bin) == 0 then
                if not warned_missing then
                    warned_missing = true
                    vim.notify('checkstyle not installed; run :MasonInstall checkstyle',
                        vim.log.levels.WARN)
                end
                return
            end
            run_checkstyle()
        end,
    })

    vim.api.nvim_create_user_command('Checkstyle', run_checkstyle,
        { desc = 'Run checkstyle on current buffer' })

    -- Trigger once on the current buffer if it's already a java file at the
    -- time setup() runs (covers the case where BufReadPost already fired
    -- before this plugin was lazy-loaded).
    if vim.bo.filetype == 'java' and vim.fn.executable(checkstyle_bin) == 1 then
        vim.schedule(run_checkstyle)
    end
end

return {
    src = {
        "mfussenegger/nvim-lint"
    },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    ft = { "java" },
    setup = init,
}
