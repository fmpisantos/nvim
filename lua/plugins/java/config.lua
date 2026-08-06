local M = {}

local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
local cache_vars = {}

local features = {
    codelens = true,
    debugger = true,
}

local function get_jdtls_paths()
    if cache_vars.paths then
        return cache_vars.paths
    end

    local path = {}

    path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'
    path.java_agent = ""

    local mason_registry = require("mason-registry")

    if mason_registry.has_package("jdtls") then
        local _ = mason_registry.get_package("jdtls")
        local jdtls_install = vim.fn.expand("$MASON/packages/jdtls")
        path.java_agent = jdtls_install .. '/lombok.jar'
        path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

        if vim.fn.has('mac') == 1 then
            path.platform_config = jdtls_install .. '/config_mac'
        elseif vim.fn.has('unix') == 1 then
            path.platform_config = jdtls_install .. '/config_linux'
        elseif vim.fn.has('win32') == 1 then
            path.platform_config = jdtls_install .. '/config_win'
        end

        path.bundles = {}

        local java_test_path = vim.fn.expand("$MASON/packages/java-test")

        local java_test_bundle = vim.split(
            vim.fn.glob(java_test_path .. '/extension/server/*.jar'),
            '\n'
        )

        if java_test_bundle[1] ~= '' then
            vim.list_extend(path.bundles, java_test_bundle)
        end

        local java_debug_path = vim.fn.expand("$MASON/packages/java-debug-adapter")

        local java_debug_bundle = vim.split(
            vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
            '\n'
        )

        if java_debug_bundle[1] ~= '' then
            vim.list_extend(path.bundles, java_debug_bundle)
        end

        path.runtimes = {
            {
                name = 'JavaSE-17',
                path = vim.fn.expand('~/.sdkman/candidates/java/17.0.16-tem'),
                default = true
            },
            {
                name = 'JavaSE-11',
                path = vim.fn.expand('~/.sdkman/candidates/java/11.0.28-tem'),
            }
        }

        cache_vars.paths = path
    else
        vim.notify("jdtls is not installed in Mason", vim.log.levels.ERROR)
    end

    return path
end

-- Rewrite lines ending with a binary operator so the operator moves to the
-- start of the next line, preserving indent. Matches Checkstyle's OperatorWrap
-- (option=NL) for tokens: + - * / % & | ^ << >> >>> == != < > <= >= && || ? ::
-- Skips lines that appear to end inside a string or line comment.
local function operator_wrap_nl(bufnr)
    -- Ordered longest-first so `>>>`, `::`, `&&`, `||`, `==`, `!=`, `<=`, `>=`,
    -- `<<`, `>>` are matched before their single-char siblings.
    local ops = {
        ">>>", "::", "&&", "||", "==", "!=", "<=", ">=", "<<", ">>",
        "+", "-", "*", "/", "%", "&", "|", "^", "?", "<", ">",
    }
    -- Compound assignment / unary suffixes we must NOT split.
    local skip_suffixes = {
        ["+"] = { "++", "+=" },
        ["-"] = { "--", "-=", "->" },
        ["*"] = { "*=", "*/" },
        ["/"] = { "/=", "//" },
        ["%"] = { "%=" },
        ["&"] = { "&=", "&&" },
        ["|"] = { "|=", "||" },
        ["^"] = { "^=" },
        ["<"] = { "<=", "<<" },
        [">"] = { ">=", ">>" },
        ["="] = { "==" },
    }

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local changed = false
    local in_block_comment = false
    local i = 1
    while i < #lines do
        local line = lines[i]

        -- Track /* ... */ block comments (including Javadoc). We must never
        -- rewrite these lines: `*` inside a Javadoc is a comment marker, not
        -- multiplication.
        local was_in_block = in_block_comment
        local scan_bc = line
        local pos = 1
        while pos <= #scan_bc do
            if in_block_comment then
                local e = scan_bc:find("%*/", pos)
                if e then
                    in_block_comment = false
                    pos = e + 2
                else
                    break
                end
            else
                local s = scan_bc:find("/%*", pos)
                if s then
                    in_block_comment = true
                    pos = s + 2
                else
                    break
                end
            end
        end

        if was_in_block or in_block_comment then
            i = i + 1
            goto continue
        end

        -- Strip line comment for detection (but keep original for output)
        local scan = line
        local dq_open = 0
        for c = 1, #scan do
            local ch = scan:sub(c, c)
            if ch == '"' and scan:sub(c - 1, c - 1) ~= '\\' then
                dq_open = 1 - dq_open
            elseif dq_open == 0 and ch == '/' and scan:sub(c + 1, c + 1) == '/' then
                scan = scan:sub(1, c - 1)
                break
            end
        end
        -- Skip lines that ended inside an unterminated string
        if dq_open ~= 0 then
            i = i + 1
        else
            local trimmed = scan:gsub("%s+$", "")
            local matched_op = nil
            for _, op in ipairs(ops) do
                if trimmed:sub(-#op) == op then
                    local prev = trimmed:sub(-#op - 1, -#op - 1)
                    local skip = false
                    -- Only single-char ops can be part of a compound we must avoid
                    if #op == 1 then
                        for _, suf in ipairs(skip_suffixes[op] or {}) do
                            if trimmed:sub(-#suf) == suf then
                                skip = true
                                break
                            end
                        end
                    end
                    -- Require a preceding space (rules out unary +/-, ->, etc.)
                    if not skip and prev == ' ' then
                        matched_op = op
                        break
                    end
                end
            end

            if matched_op and lines[i + 1] then
                local next_line = lines[i + 1]
                local indent = next_line:match("^(%s*)") or ""
                local new_current = trimmed:sub(1, -#matched_op - 1):gsub("%s+$", "")
                local new_next = indent .. matched_op .. " " .. next_line:gsub("^%s+", "")
                lines[i] = new_current
                lines[i + 1] = new_next
                changed = true
            end
            i = i + 1
        end
        ::continue::
    end

    if changed then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end
end
M.operator_wrap_nl = operator_wrap_nl

-- Normalize Javadoc paragraphs to satisfy Checkstyle's JavadocParagraph:
--   1. Collapse repeated leading `* ` before `<p>` (e.g. ` * * <p>` → ` * <p>`).
--   2. Inside a Javadoc block, bare empty lines become ` *` (indent-preserving).
--   3. Every ` * <p>` line must be preceded by a ` *` (empty comment) line;
--      insert one when missing.
local function javadoc_paragraph_fix(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local in_block = false
    local block_indent = ""
    local changed = false

    -- Pass 1: collapse doubled `* ` before <p>, and normalize bare empty lines
    for i, line in ipairs(lines) do
        local start_indent = line:match("^(%s*)/%*%*")
        if start_indent then
            in_block = true
            block_indent = start_indent
        end

        if in_block then
            -- If the line has extra `* ` sequences between the leading `*` and
            -- a marker like `<p>`, `@param`, `@return`, `@throws`, `@deprecated`,
            -- `@see`, `@author`, `@since`, `@version`, `@link`, strip them.
            -- Also strip a stray identifier that got injected before <p>.
            local markers = { "<p>", "@param", "@return", "@throws", "@deprecated",
                              "@see", "@author", "@since", "@version" }
            local marker_pos = nil
            local marker_str = nil
            for _, mk in ipairs(markers) do
                local p = line:find(mk, 1, true)
                if p and (not marker_pos or p < marker_pos) then
                    marker_pos = p
                    marker_str = mk
                end
            end

            if marker_pos then
                local head = line:sub(1, marker_pos - 1)
                local tail = line:sub(marker_pos)
                -- head should be `<indent>* ` followed by only whitespace/`*`/junk.
                -- Detect and normalize when head contains extra `*` markers.
                local indent, after_first_star = head:match("^(%s*)%*(.*)$")
                if indent and after_first_star and after_first_star:find("%*") then
                    local new = indent .. "* " .. tail
                    if new ~= line then
                        line = new
                        lines[i] = line
                        changed = true
                    end
                end
            end

            -- Bare empty line inside a javadoc block → `<indent> *`
            if line:match("^%s*$") then
                local new = block_indent .. " *"
                if new ~= line then
                    lines[i] = new
                    changed = true
                end
            end
        end

        if in_block and line:find("%*/") then
            in_block = false
            block_indent = ""
        end
    end

    -- Pass 2: dedupe consecutive blank comment lines and ensure a blank comment
    -- line precedes every `<p>` line.
    local out = {}
    in_block = false
    for _, line in ipairs(lines) do
        if line:match("^%s*/%*%*") then in_block = true end

        local is_blank_comment = in_block and line:match("^%s*%*%s*$") ~= nil
        local prev = out[#out] or ""
        local prev_blank = in_block and prev:match("^%s*%*%s*$") ~= nil

        if is_blank_comment and prev_blank then
            -- Collapse consecutive blank comment lines
            changed = true
        else
            if in_block then
                local pi = line:match("^(%s*)%* <p>")
                if pi then
                    if prev:match("^%s*%*%s*$") == nil then
                        table.insert(out, pi .. "*")
                        changed = true
                    end
                end
            end
            table.insert(out, line)
        end

        if in_block and line:find("%*/") then in_block = false end
    end

    if changed then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
    end
end
M.javadoc_paragraph_fix = javadoc_paragraph_fix

local function enable_debugger(_)
    local dap_config = require("plugins.java.dap_java_config");
    dap_config.setup_dap()
    dap_config.setup_dap_main_class_configs()

    -- Add attach configuration
    local dap = require('dap')
    dap.configurations.java = dap.configurations.java or {}
    table.insert(dap.configurations.java, {
        type = 'java',
        request = 'attach',
        name = 'Attach to running JVM',
        hostName = 'localhost',
        port = 5005,
    })
end

local function enable_codelens(bufnr)
    local function refresh()
        pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
    end

    refresh()

    vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        group = java_cmds,
        desc = 'refresh codelens',
        callback = function()
            refresh()
        end,
    })
end

function M.jdtls_on_attach(_, bufnr)
    if features.debugger then
        enable_debugger(bufnr)
    end

    if features.codelens then
        enable_codelens(bufnr)
    end

    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)

    vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        group = java_cmds,
        desc = 'organize imports and format Java buffer on save',
        callback = function()
            if vim.b[bufnr].format_in_progress then return end
            pcall(function() require('jdtls').organize_imports() end)
            pcall(vim.lsp.buf.format, { async = false, bufnr = bufnr, timeout_ms = 10000 })
            pcall(javadoc_paragraph_fix, bufnr)
            pcall(operator_wrap_nl, bufnr)
        end,
    })
end

function M.clear_data_dir()
    local path = get_jdtls_paths()
    local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    vim.fn.delete(data_dir, 'rf')
end

function M.jdtls_setup(_)
    local path = get_jdtls_paths()
    local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    local cmd = {
        vim.fn.expand('~/.sdkman/candidates/java/21.0.9-tem/bin/java'),
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. path.java_agent,
        '-Xms2g',
        '-Xmx4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',

        -- 💀
        '-jar',
        path.launcher_jar,

        -- 💀
        '-configuration',
        path.platform_config,

        -- 💀
        '-data',
        data_dir,
    }

    -- path.formatterUrl = vim.fn.expand("~/.config/nvim/lua/4LabsStyle.xml");
    -- path.formatterUrl = vim.fn.expand("~/Projects/n4b-services/.vscode/settings.json");
    path.formatterUrl = vim.fn.expand("~/Projects/n4b-services/.vscode/formatter.xml");

    return cmd, path
end

return M
