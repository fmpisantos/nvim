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

local shared_buffs = require("awman.myPlugins.shared_buffer");
local state, save = shared_buffs.setup("notes")
if state == nil then
    return
end

local function contains(str1, str2)
    local escaped_str2 = str2:gsub("([%-%+%[%]%(%)%^%$%%%?%.])", "%%%1");
    return string.find(str1, escaped_str2) ~= nil
end

local function parse_path(path)
    if path == nil then
        return path
    end
    path = string.gsub(path, "\\", "/")
    path = string.gsub(path, "//", "/")
    return path
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

    local todo_file = io.open(notes_path .. "/todo.md", "w")
    if todo_file then
        todo_file:write("# TODOS:\n\n## Open:\n\n## Closed:")
        todo_file:close()
    end

    vim.cmd(":edit!");
    oil.open(projectName);
    vim.cmd(":edit!");
    update_path(notes_path);
end

local function is_in_path(base_path)
    local current_dir = parse_path(vim.fn.expand("%:p"))
    base_path = parse_path(base_path)
    current_dir = parse_path(current_dir)
    if not current_dir or current_dir == "" then
        return false
    end

    return contains(current_dir, base_path)
end

local function get_next_id(prefix)
    local notes = vim.fn.glob(state.path .. "/" .. prefix .. "*.md", false, true)
    local max = 0
    for _, note in ipairs(notes) do
        local id = tonumber(note:match("note(%d+).md"))
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

local function create_note()
    vim.cmd("edit " .. state.path .. "/notes/" .. "note" .. get_next_id("note") .. ".md")
end

local function create_todo()
    vim.cmd("edit " .. state.path .. "/todos/" .. "todo" .. get_next_id("todo") .. ".md")
    vim.api.nvim_put({ "!TODO", "" }, "l", false, true)
    vim.cmd("normal! G")
end

local function is_in_todo_done()
    return is_in_path(state.path .. "/todos/done")
end

local function type_of_file_location()
    local current_file = vim.fn.expand("%:p")
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

local function is_in_todo(path)
    path = path or state.path
    return is_in_path(state.path .. "/todos")
end

local function append_to_first_line(filepath, new_first_line)
    local file = io.open(filepath, "r")
    local content = ""
    if file then
        content = file:read("*a")
        file:close()
    else
        print("Error: Unable to open file.")
        return
    end

    file = io.open(filepath, "w")
    if file then
        file:write(new_first_line)
        file:write(content)
        file:close()
    else
        print("Error: Unable to open file for writing.")
    end
end

local function move_file(source, destination)
    local success, err = os.rename(source, destination)
    if not success then
        print("Error moving file:", err)
        return
    end
    vim.cmd("bdelete");
    vim.cmd("edit " .. destination);
end

local function make_todo()
    if is_in_todo() then
        local file = io.open(vim.fn.expand('%:p'), "r");
        if not file then
            print("Error: Unable to open note file.");
            return;
        end
        local line = file:read("*l");
        file:close();
        if contains(line, tags.todo) then
            return
        else
            append_to_first_line(vim.fn.expand('%:p'), tags.todo .. "\n\n")
        end
    else
        append_to_first_line(vim.fn.expand("%:p"), tags.todo .. "\n\n")
        move_file(vim.fn.expand("%:p"), state.path .. "/todos/" .. vim.fn.expand("%:t"))
    end
end

local function make_note(filepath)
    filepath = filepath or vim.fn.expand("%:p")

    if not filepath or filepath == "" then
        print("Error: Invalid file path.")
        return
    end

    if is_in_todo(filepath) then
        local file = io.open(filepath, "r")
        if not file then
            print("Error: Unable to open the file for reading.")
            return
        end

        local lines = {}
        for line in file:lines() do
            if not contains(line, tags.todo) then
                table.insert(lines, line)
            end
        end
        file:close()

        file = io.open(filepath, "w")
        if not file then
            print("Error: Unable to open the file for writing.")
            return
        end

        for _, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()

        if not state or not state.path then
            print("Error: Invalid state or path.")
            return
        end
        local notes_dir = state.path .. "/notes/"
        local target_path = notes_dir .. vim.fn.fnamemodify(filepath, ":t")

        move_file(filepath, target_path)
    end
end

local function open_floating_window()
    if floating_window.win ~= -1 then
        vim.api.nvim_win_hide(floating_window.win)
        return
    end
    floating_window = CreateFloatingWindow { buf = floating_window.buf }
end

local function open_notes()
    open_floating_window()
    vim.cmd("edit " .. state.path .. "/notes")
end

local function open_todos()
    open_floating_window()
    vim.cmd("edit " .. state.path .. "/todos.md")
end

local function open_new_note()
    open_floating_window()
    create_note()
end

local function open_new_todo()
    open_floating_window()
    create_todo()
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

local function _update_todo_md(func, to_remove)
    local file = io.open(state.path .. "/todos.md", "r+");
    local hasStarted = false;
    local isOpened = true;
    local opened = {};
    local closed = {};
    if not file then
        vim.print("Error: Unable to open todos.md file.");
        return
    end

    local lines = {}
    for line in file:lines() do
        if contains(line, "## Open:") then
            hasStarted = true;
        end
        if contains(line, "## Closed:") then
            isOpened = false;
        end
        if func(line, lines) then
            if hasStarted then
                if isOpened then
                    table.insert(opened, line);
                else
                    table.insert(closed, line);
                end
            end
            table.insert(lines, line)
        end
    end
    file:close()

    file = io.open(state.path .. "/todos.md", "w")
    if not file then
        return;
    end

    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()

    local _to_remove = {};
    if to_remove then
        for _, line in ipairs(state.closed) do
            if not closed[line] then
                table.insert(_to_remove, line);
            end
        end
        for _, line in ipairs(state.opened) do
            if not opened[line] then
                table.insert(_to_remove, line);
            end
        end
    end

    state.opened = opened;
    state.closed = closed;
    if not save then
        print("Error: Unable to save state.");
        return;
    end
    save(state);
    return _to_remove;
end

local function add_file(to, filepath)
    local note = io.open(filepath, "r+");
    if note == nil then
        print("Error: Unable to open note file (" .. filepath .. ")");
        return;
    end

    local title = "";
    for line in note:lines() do
        if contains(line, "# ") then
            title = line;
            break;
        end
    end
    note:close();
    if title == nil then
        title = vim.fn.expand("%:t:r")
    else
        title = title:sub(3);
    end

    local append = "";
    if to == "todo" then
        append = "- [ ] [" .. title .. "](" .. filepath .. ")\n";
    else
        append = "- [x] [" .. title .. "](" .. filepath .. ")\n";
    end

    local idx = 0;
    _update_todo_md(function(line, lines)
        if contains(line, "## Closed:") then
            if to == "todo" then
                lines[idx] = append;
            else
                lines[idx] = line;
                lines[idx + 1] = append;
                return false;
            end
            idx = idx + 1;
        end
        idx = idx + 1;
        return true;
    end);
end

local function remove_file(filename)
    _update_todo_md(function(line, _)
        if contains(line, "](" .. filename .. ")") then
            return false
        end
        return true
    end)
end

local function update_todo_md(to, from, filepath)
    if to == "todo" then
        if from == "done" then
            remove_file(filepath)
        end
        add_file(to, filepath)
    else
        if to == "done" then
            if from == "todo" then
                remove_file(filepath)
            end
            add_file(to, filepath)
        else
            if to == "note" then
                remove_file(filepath)
            end
        end
    end
end

local function update_title()
    local file = io.open(vim.fn.expand("%:p"), "r+")
    if not file then
        return
    end

    local title = nil
    for line in file:lines() do
        if contains(line, "# ") then
            title = line:sub(3)
            break;
        end
    end
    file:close()

    if title == nil then
        return
    end

    _update_todo_md(function(line, lines)
        if contains(line, "](" .. vim.fn.expand("%:p") .. ")") then
            lines[#lines] = "  - [ ] [" .. title .. "](" .. vim.fn.expand("%:p") .. ")"
        end
        return true;
    end);
end

local function on_file_save_check()
    local oldtype = type_of_file_location();
    if is_in_todo() then
        local todo, done = get_todo_info()
        if todo then
            if is_in_todo_done() then
                if not done then
                    move_file(vim.fn.expand("%:p"), state.path .. "/todos/" .. vim.fn.expand("%:t"))
                    update_todo_md("todo", oldtype, vim.fn.expand("%:p"))
                else
                    update_title()
                end
            else
                if done then
                    move_file(vim.fn.expand("%:p"), state.path .. "/todos/done/" .. vim.fn.expand("%:t"))
                    update_todo_md("done", oldtype, vim.fn.expand("%:p"))
                else
                    update_title()
                end
            end
        else
            move_file(vim.fn.expand("%:p"), state.path .. "/notes/" .. vim.fn.expand("%:t"))
            update_todo_md("notes", oldtype, vim.fn.expand("%:p"))
        end
    else
        local todo, done = get_todo_info()
        if todo then
            if done then
                move_file(vim.fn.expand("%:p"), state.path .. "/todos/done/" .. vim.fn.expand("%:t"))
                update_todo_md("done", oldtype, vim.fn.expand("%:p"))
            else
                move_file(vim.fn.expand("%:p"), state.path .. "/todos/" .. vim.fn.expand("%:t"))
                update_todo_md("todo", oldtype, vim.fn.expand("%:p"))
            end
        end
    end
end

local function type_of_file(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return "note"
    end

    local line = file:read("*l")
    file:close()

    for _, tag in ipairs(tags.done) do
        if contains(line, tag) then
            return "done"
        end
    end

    if contains(line, tags.todo) then
        return "todo"
    end

    return "note"
end

local function on_file_moved(old_path, new_path)
    local new_type = type_of_file(new_path)
    local old_type = type_of_file(old_path)
    if new_type == old_type then
        return
    end
    if new_type == "todo" then
        if old_type == "note" then
            remove_file(old_path)
        else
            update_todo_md("todo", "done", new_path)
        end
    else
        if new_type == "done" then
            if old_type == "todo" then
                update_todo_md("done", "todo", new_path)
            else
                remove_file(old_path)
            end
        else
            remove_file(old_path)
        end
    end
end

local function on_file_delete(filepath)
    local type = type_of_file(filepath)
    if type ~= "note" then
        remove_file(filepath)
    end
end

local function on_todo_md_save()
    local update = {};
    local hasStarted = false;
    local isOpen = true;
    local to_remove = _update_todo_md(function(line, _)
        if contains(line, "## Open:") then
            hasStarted = true;
            return true;
        end
        if hasStarted then
            if contains(line, "## Closed:") then
                isOpen = false;
            end
            if isOpen then
                if not state.opened[line] then
                    table.insert(update, {
                        from = state.closed[line] and "done" or "note",
                        to = "todo",
                        line = line
                    });
                end
            else
                if not state.closed[line] then
                    table.insert(update, {
                        from = state.opened[line] and "todo" or "note",
                        to = "done",
                        line = line
                    });
                end
            end
        end
        return true
    end, true);

    for _, file in ipairs(to_remove) do
        local filePath = file:match("%((.-)%)");
        if not filePath then
            goto continue;
        end

        make_note(filePath);
        ::continue::
    end

    for _, info in ipairs(update) do
        local match = info.line:match("(%d+)%%")
        if match then
            update_todo_md(info.to, info.from, match);
        end
    end
end

local function is_note_folder()
    return is_in_path(state.path)
end

function M.setup()
    vim.api.nvim_create_user_command("NotesSetup", create_notes_directory, { nargs = 0 })
    vim.api.nvim_create_user_command("Notes", open_notes, { nargs = 0 })
    vim.api.nvim_create_user_command("Todos", open_todos, { nargs = 0 })
    vim.api.nvim_create_user_command("Note", open_new_note, { nargs = 0 })
    vim.api.nvim_create_user_command("Todo", open_new_todo, { nargs = 0 })
    vim.api.nvim_create_user_command("MakeTodo", make_todo, { nargs = 0 })
    vim.api.nvim_create_user_command("MakeNote", make_note, { nargs = 0 })

    if not is_note_folder() then
        return
    end

    local old_path = nil
    vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function()
            local current_path = vim.fn.expand('%:p');
            if old_path and old_path ~= current_path then
                on_file_moved(old_path, current_path);
            else
                on_file_save_check();
            end
            old_path = current_path
        end,
    });

    vim.api.nvim_create_autocmd('BufUnload', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function()
            old_path = vim.fn.expand('%:p')
        end,
    });

    vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { state.path .. '/todos.md' },
        callback = function()
            on_todo_md_save()
        end,
    });

    vim.api.nvim_create_autocmd('BufDelete', {
        pattern = { state.path .. '/notes/**', state.path .. '/todos/**' },
        callback = function(event)
            local filepath = vim.api.nvim_buf_get_name(event.buf)
            on_file_delete(filepath)
        end,
    })
end

M.setup()
