-- Utility to run a callback only when one of the given paths belongs to a specific git repo
-- Usage:
-- local r = require('run_on_repo')
-- r.setup {
--   root = '/abs/path/to/repo',         -- optional exact git root match
--   url = 'github.com/me/repo',         -- optional remote url (substring allowed)
--   match = 'myorg',                    -- optional substring matched against name or remote
--   on_match = function(repo_root, path) -- callback when match found
--     -- run whatever you need, repo_root is the repository top level
--   end,
-- }

local M = {}

local uv = vim.loop
local fn = vim.fn

local function is_dir(path)
    if not path or path == '' then return false end
    local stat = uv.fs_stat(path)
    return stat and stat.type == 'directory'
end

local function realpath(p)
    if not p or p == '' then return p end
    local ok, r = pcall(uv.fs_realpath, p)
    if ok and r and r ~= '' then return r end
    return fn.resolve(p)
end

local function git_toplevel(path)
    if not path or path == '' then return nil end
    local cmd = { 'git', '-C', path, 'rev-parse', '--show-toplevel' }
    local out = fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 or not out or #out == 0 then return nil end
    return realpath(out[1])
end

local function git_remote_origin(repo_root)
    if not repo_root then return nil end
    local cmd = { 'git', '-C', repo_root, 'config', '--get', 'remote.origin.url' }
    local out = fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 or not out or #out == 0 then return nil end
    return out[1]
end

-- Extract the repository path (namespace and repo name) from a git remote URL.
-- Examples:
--   git@github.com:owner/repo.git -> owner/repo
--   https://github.com/owner/repo.git -> owner/repo
--   ssh://git@host/group/subgroup/repo.git -> group/subgroup/repo
local function remote_repo_path(remote)
    if not remote or remote == '' then return nil end
    local s = remote
    -- strip trailing .git
    s = s:gsub('%.git$', '')
    -- remove protocol (scheme) e.g. ssh://, https://, git://
    s = s:gsub('^%w+://', '')
    -- remove user@ if present: git@host/path or user@host:path
    s = s:gsub('^[^@]+@', '')
    -- convert scp-like colon to slash: host:owner/repo -> host/owner/repo
    s = s:gsub(':', '/')
    -- drop the leading host segment if present: host/owner/repo -> owner/repo
    local path = s:match('^[^/]+/(.+)$') or s
    -- normalize any duplicated slashes
    path = path:gsub('//+', '/')
    return path
end

-- Normalize an input string provided by user in opts.url or opts.match to the
-- repository path (owner[/subgroup...]/repo) without any host or .git suffix.
local function normalize_repo_input(s)
    if not s or s == '' then return nil end
    -- reuse remote_repo_path which already strips .git and host/protocol
    return remote_repo_path(s)
end

-- Collect candidate paths: cwd and all buffer paths (files or directories)
local function collect_candidate_dirs()
    local seen = {}
    local list = {}

    local function add(p)
        if not p or p == '' then return end
        if not seen[p] then
            seen[p] = true; table.insert(list, p)
        end
    end

    add(realpath(vim.loop.cwd()))

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name and name ~= '' then
                local abs = fn.fnamemodify(name, ':p')
                if is_dir(abs) then
                    add(realpath(abs))
                else
                    add(realpath(fn.fnamemodify(abs, ':h')))
                end
            end
        end
    end

    return list
end

-- options: { root=..., url=..., match=..., on_match=function(repo_root, path) end }
function M.setup(opts)
    opts = opts or {}
    local on_match = opts.on_match
    if type(on_match) ~= 'function' then
        vim.notify('run_on_repo: missing on_match callback', vim.log.levels.ERROR)
        return false
    end

    local candidates = collect_candidate_dirs()
    for _, path in ipairs(candidates) do
        if path and path ~= '' then
            local repo = git_toplevel(path)
            if repo then
                local matched = false
                if opts.root then
                    local rootp = realpath(opts.root)
                    if rootp and rootp == repo then matched = true end
                end
                if not matched and opts.url then
                    local remote = git_remote_origin(repo)
                    local rpath = remote and remote_repo_path(remote) or nil
                    local want = normalize_repo_input(opts.url)
                    -- match strictly against the normalized repository path
                    if rpath and want and (rpath == want or string.find(rpath, want, 1, true)) then
                        matched = true
                    end
                end
                if not matched and opts.match then
                    local remote = git_remote_origin(repo) or ''
                    local rpath = remote_repo_path(remote) or ''
                    local want = normalize_repo_input(opts.match)
                    if want and rpath and string.find(rpath, want, 1, true) then
                        matched = true
                    end
                end

                if matched then
                    local ok, err = pcall(on_match, repo, path)
                    if not ok then
                        vim.notify('run_on_repo: on_match callback errored: ' .. tostring(err), vim.log.levels.ERROR)
                    end
                    return true
                end
            end
        end
    end

    return false
end

return M
