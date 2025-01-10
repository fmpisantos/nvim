local M = {}

local oil = require("oil")

local tags = {
    todo = "!TODO",
    done = { "!TODO (DONE)", "!TODO (Done)", "!TODO (done)", "!TODO(DONE)", "!TODO(Done)", "!TODO(done)" }
}

local floating_window = {
    buf = -1,
    win = -1
}

local pre = {}

local shared_buffs = require("awman.myPlugins.shared_buffer");
local state, save = shared_buffs.setup("notes")
if state == nil then
    return
end

local function is_directory(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory"
end

local function open_floating_window()
    if floating_window.win ~= -1 and vim.api.nvim_win_is_valid(floating_window.win) then
        vim.api.nvim_win_hide(floating_window.win)
        return
    end
    floating_window = CreateFloatingWindow { buf = floating_window.buf, keepStyle = true };
end

local function get_location_from_type(type)
    if type == "todo" then
        return state.path .. "/todos"
    else
        if type == "done" then
            return state.path .. "/todos/done"
        end
    end
    return state.path .. "/notes"
end

local function move_file(source, destination)
    if is_directory(destination) then
        destination = destination .. "/" .. vim.fn.fnamemodify(source, ":t")
    end
    local success, err = os.rename(source, destination)
    if not success then
        vim.print("Error moving file:", err)
        return
    end

    vim.api.nvim_buf_set_name(vim.api.nvim_get_current_buf(), destination);
end

local function parse_path(path)
    if path == nil then
        return path
    end
    path = string.gsub(path, "\\", "/")
    path = string.gsub(path, "//", "/")
    return path
end

local function contains(str1, str2)
    local clean_str1 = parse_path(str1:lower():gsub("%[.*%]", ""):gsub("[()%[%]]", ""))
    local clean_str2 = parse_path(str2:lower():gsub("%[.*%]", ""):gsub("[()%[%]]", ""))
    return clean_str1:find(clean_str2, 1, true) ~= nil
end

local function starts_with(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function is_in_path_dir(base_path)
    local current_dir = parse_path(oil.get_current_dir())
    base_path = parse_path(base_path)
    current_dir = parse_path(current_dir)
    if not current_dir or current_dir == "" then
        return false
    end

    return contains(current_dir, base_path)
end

local function is_note_folder()
    if not state.path then
        return
    end
    return is_in_path_dir(state.path)
end

local function update_path(path)
    if (path == nil) then
        path = vim.fn.expand('%:p')
    end
    if (save == nil) then
        return
    end
    path = parse_path(path)
    state.path = path
    if state.opened == nil then
        state.opened = {}
    end
    if state.closed == nil then
        state.closed = {}
    end
    save(state)
end

local function get_todo_info()
    local file = io.open(vim.fn.expand('%:p'), "r");
    if not file then
        return false, false
    end
    local line = file:read("*l")
    file:close();
    if contains(line, tags.todo) then
        for _, tag in ipairs(tags.done) do
            if contains(line, tag) then
                return true, true
            end
        end
        return true, false
    else
        return false, false;
    end
end

local function create_notes_directory()
    local projectName = vim.fn.input("Enter project name: ")
    if projectName == nil or projectName == "" then
        return
    end

    local path = oil.get_current_dir()
    local notes_path = path .. "/" .. projectName

    local function create_dir(dir_path)
        if vim.loop.fs_stat(dir_path) == nil then
            vim.loop.fs_mkdir(dir_path, 511)
        end
    end

    create_dir(notes_path)

    create_dir(notes_path .. "/notes")
    create_dir(notes_path .. "/todos")
    create_dir(notes_path .. "/todos/done")

    io.open(notes_path .. "/notes/.gitkeep", "w"):close()
    io.open(notes_path .. "/todos/.gitkeep", "w"):close()
    io.open(notes_path .. "/todos/done/.gitkeep", "w"):close()

    local todo_file = io.open(notes_path .. "/todos.md", "w")
    if todo_file then
        todo_file:write("# TODOS:\n\n## Open:\n\n## Closed:")
        todo_file:close()
    end

    vim.cmd(":edit!");
    oil.open(projectName);
    vim.cmd(":edit!");
    update_path(notes_path);
end

local function type_of_file_location(path)
    local current_file = vim.fn.expand(path .. ":p")
    current_file = parse_path(current_file)
    local base_path = parse_path(state.path)
    if not current_file or current_file == "" then
        return false
    end
    if contains(current_file, base_path .. "/todos/done") then
        return "done"
    end
    if contains(current_file, base_path .. "/todos") then
        return "todo"
    end
    return "note"
end

local function update_state(oldType, newType, oldPath, newPath, title)
    -- vim.print("Updating state");
    -- vim.print("oldType: " .. (oldType or "") ..
    --     " newType: " .. newType ..
    --     " oldPath: " .. (oldPath or "") ..
    --     " newPath: " .. newPath ..
    --     " title: " .. title);
    -- vim.print("oldState: " .. vim.inspect(state));
    if state == nil then
        return;
    end
    if state.closed == nil then
        state.closed = {};
    end
    if state.opened == nil then
        state.opened = {};
    end
    if oldType == "todo" then
        state.opened[oldPath] = nil;
    else
        if oldType == "done" then
            state.closed[oldPath] = nil;
        end
    end
    if newType == "todo" then
        state.opened[newPath] = title;
    else
        if newType == "done" then
            state.closed[newPath] = title;
        end
    end
    -- vim.print("state: " .. vim.inspect(state));

    save(state);
end

local function get_title(path)
    local file = io.open(path, "r");
    if not file then
        return nil;
    end
    for line in file:lines() do
        if line:find("#") then
            file:close();
            return line;
        end
    end
    file:close();
    return nil;
end

local function update_todos_md()
    -- vim.print("Updating todos.md");
    -- vim.print(state);
    local todo_file = io.open(state.path .. "/todos.md", "w")
    if todo_file then
        todo_file:write("# TODOS:\n\n## Open:\n")
        for path, title in pairs(state.opened) do
            todo_file:write("- [ ] [" .. title .. "](" .. path .. ")\n")
        end
        todo_file:write("\n## Closed:\n")
        for path, title in pairs(state.closed) do
            todo_file:write("- [x] [" .. title .. "](" .. path .. ")\n")
        end
        todo_file:close()
    end
end

local function update_first_line(newPath, newType)
    vim.print("Updating first line");
    -- vim.print("newPath: " .. newPath);
    -- vim.print("newType: " .. newType);
    if newPath == nil or newPath == "" then
        return;
    end
    local file = io.open(newPath, "r");
    if not file then
        return;
    end
    local lines = file:lines();
    local newLines = {}
    local newLine = newType == "todo" and tags.todo or tags.done[1];
    vim.print(newLine);
    for line in lines do
        if #newLines == 0 then
            for _, tag in ipairs(tags.done) do
                if contains(line, tag) then
                    if newType == "notes" then
                        goto continue
                    end
                    vim.print("Skipping line(from done): " .. line);
                    vim.print("For line: " .. newLine);
                    table.insert(newLines, newLine);
                    goto continue
                end
            end
            if contains(line, tags.todo) then
                if newType == "notes" then
                    goto continue
                end
                vim.print("Skipping line(from todo): " .. line);
                vim.print("For line: " .. newLine);
                table.insert(newLines, newLine);
                goto continue
            end
            vim.print("Skipping line(): " .. line);
            vim.print("For line: " .. newLine);
            table.insert(newLines, newLine);
            table.insert(newLines, "\n");
            goto continue
        end
        if #newLines == 1 and (line == "" or line == "\n") and newType == "notes" then
            goto continue
        end
        table.insert(newLines, line);
        ::continue::
    end
    file:close();
    file = io.open(newPath, "w");
    if file then
        for i, line in ipairs(newLines) do
            if i ~= 1 then
                file:write("\n");
            end
            file:write(line);
        end
        file:close();
    end
end

local function new_file(path)
    local todo, done = get_todo_info();
    local type = "note";
    if done then
        type = "done";
    else
        if todo then
            type = "todo";
        end
    end
    update_state(nil, type, nil, path, get_title(path));
    update_todos_md();
end

local function update(_oldPath, newType, dont_update_todos_md, newPath)
    -- vim.print("update(" ..
    --     tostring(_oldPath) ..
    --     ", " .. tostring(newType) .. ", " .. tostring(dont_update_todos_md) .. ", " .. tostring(newPath) ..
    --     ")");
    dont_update_todos_md = dont_update_todos_md or false;
    if not _oldPath then
        _oldPath = vim.fn.expand('%:p');
    end
    local oldType = type_of_file_location(_oldPath);

    if not newType then
        local todo, done = get_todo_info();
        if todo then
            if done then
                newType = "done";
            else
                newType = "todo";
            end
        else
            newType = "note";
        end
    else
        update_first_line(_oldPath, newType);
    end
    newPath = newPath or get_location_from_type(newType) .. "/" .. vim.fn.fnamemodify(_oldPath, ":t");

    local title = get_title(newPath) or newPath;
    if newType ~= oldType then
        update_state(oldType, newType, _oldPath, newPath, title)
        move_file(_oldPath, newPath);
    end
    if not dont_update_todos_md then
        update_todos_md();
    end
end

local function on_file_delete(filepath)
    vim.print("on_file_delete(" .. filepath .. ")");
    local type = type_of_file_location(filepath);
    vim.print(state);
    if type == "todo" then
        state.opened[filepath] = nil;
    else
        if type == "done" then
            state.closed[filepath] = nil;
        end
    end
    save(state);
    update_todos_md();
end

local function on_todos_md_updated()
    local file = io.open(state.path .. "/todos.md", "r");
    if not file then
        return;
    end
    local lines = file:lines();
    local opened = {}
    local closed = {}
    local to_update = {}
    local to_remove = {}
    local hasStarted = false;
    for line in lines do
        if starts_with(line, "## Open:") then
            hasStarted = true;
            goto continue
        end
        if starts_with(line, "## Closed:") then
            hasStarted = true;
            goto continue
        end
        if not hasStarted then
            goto continue
        end
        if line and line ~= "" then
            local checkbox = line:match("%- %[(%S)%]") == "x";
            local title = line:match("%[(.-)%]");
            local path = line:match("%((.-)%)");

            if checkbox then
                closed[path] = title;
                if not state.closed[path] then
                    to_update[path] = { type = "done", title };
                end
            else
                opened[path] = title;
                if not state.opened[path] then
                    to_update[path] = { type = "todo", title };
                end
            end
        end
        ::continue::
    end
    file:close();
    for path, _ in pairs(state.opened) do
        if not closed[path] and not opened[path] then
            to_remove[path] = true;
        end
    end
    for path, _ in pairs(state.closed) do
        if not closed[path] and not opened[path] then
            to_remove[path] = true;
        end
    end
    for path, title in pairs(to_update) do
        update(path, title.type, true, get_location_from_type(title.type) .. "/" .. vim.fn.fnamemodify(path, ":t"));
    end
    for path, _ in pairs(to_remove) do
        update(path, "notes", true, get_location_from_type("notes") .. "/" .. vim.fn.fnamemodify(path, ":t"));
    end
    update_todos_md();
end

local function open(path)
    open_floating_window();
    vim.cmd("edit " .. path);
    vim.cmd("normal! G$");
end

local function get_next_id(path, prefix)
    local notes = vim.fn.glob(path .. "/" .. prefix .. "*.md", false, true)
    local max = 0
    for _, note in ipairs(notes) do
        local id = tonumber(note:match(prefix .. "(%d+).md"))
        if not id then
            goto continue
        end
        if id > max then
            max = id
        end
        ::continue::
    end
    return max + 1
end

local function open_new_todo()
    local id = get_next_id(state.path .. "/todos", "todo");
    local path = state.path .. "/todos/todo" .. id .. ".md";
    local file = io.open(path, "w");
    if file then
        file:write("!TODO\n\n# ");
        file:close();
    end
    pre[path] = true;
    open(path);
end

function M.setup()
    vim.api.nvim_create_user_command("NotesSetup", create_notes_directory, { nargs = 0 })
    vim.api.nvim_create_user_command("Notes", function()
        open(state.path .. "/notes");
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("Todos", function()
        open(state.path .. "/todos");
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("Note", function()
        local id = get_next_id(state.path .. "/notes", "note");
        local path = state.path .. "/notes/note" .. id .. ".md";
        open(path);
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("Todo", open_new_todo, { nargs = 0 })

    if not is_note_folder() then
        return
    end

    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function()
            local current_path = vim.fn.expand('%:p');
            if pre[current_path] then
                return
            end
            pre[current_path] = vim.fn.filereadable(current_path) == 0
        end,
    });

    vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function()
            local current_path = vim.fn.expand('%:p');
            if pre[current_path] then
                new_file(current_path);
            else
                update();
            end
            pre[current_path] = false;
        end,
    });

    vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { state.path .. '/todos.md' },
        callback = function()
            on_todos_md_updated()
        end,
    });

    vim.api.nvim_create_autocmd('BufDelete', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function(event)
            vim.print("BufDelete");
            local filepath = vim.api.nvim_buf_get_name(event.buf)
            on_file_delete(filepath)
        end,
    });

    require("awman.myPlugins.oilAutoCmd").setup(
        function(path)
            on_file_delete(path)
        end,
        function(src, dest)
            update(src, type_of_file_location(dest), true, dest)
            update_todos_md()
        end,
        { state.path .. "/notes/**", state.path .. "/todos/**" }
    );
end

-- For testing
state.opened = {}
state.closed = {}
save(state)
M.setup()

return M;
