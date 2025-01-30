local nmap = function(keys, func, desc)
    if desc then
        desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { desc = desc })
end
-- Remaps
local CompileFile = function()
    -- Get the current file's full path
    local file_path = vim.fn.expand('%:p')

    -- Build the command
    local command = 'powershell.exe -File W:\\env\\etc\\crossbow\\validation\\sihot_style_compiler.ps1 -FILE ' ..
        file_path

    vim.print(command);

    -- Execute the command and capture the output
    local output = vim.fn.system(command)

    -- Print the output
    print(output)
end

-- Create a command to call the function
vim.api.nvim_create_user_command('CompileFile', CompileFile, {})

-- Optionally, you can map the function to a key binding
vim.keymap.set('n', '<C-F7>', ':CompileFile<CR>', { desc = 'Run CompileFile command' })

-- Named functions

local function getVersionString(v)
    if v < 10 then
        return "00" .. v
    elseif v < 100 then
        return "0" .. v
    end
    return v
end

local function addDeprecatedInfo(deprecated_info)
    deprecated_info = deprecated_info or ""
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false);
    local service_name;
    local versionInt;
    local id_line = 0;
    local description_end_line = 0;
    for i, line in ipairs(lines) do
        if line:find("<ID>") and line:find("</ID>") then
            id_line = i
            service_name, versionInt = string.match(line, "<ID>(.-)_V(%d%d%d)</ID>");
        end
        if line:find("</Description>") then
            description_end_line = i;
            break;
        end
    end
    if id_line == 0 or description_end_line == 0 then
        print("Error: Unable to locate <ID>...</ID>  or </Description> in current buffer.");
        return
    end
    local version_string = getVersionString(tonumber(versionInt) + 1);
    local deprecated_section = "\t<Deprecated>\n\t\t<Reference Service=\"" ..
        service_name .. "_V" .. version_string .. "\" Text=\"" .. deprecated_info .. "\"/>\n\t</Deprecated>"

    local replacement_lines = { "" }
    for line in deprecated_section:gmatch("[^\r\n]+") do
        table.insert(replacement_lines, line)
    end

    vim.api.nvim_buf_set_option(0, "modifiable", true)
    vim.api.nvim_buf_set_lines(0, description_end_line, description_end_line, false, replacement_lines)
    vim.api.nvim_command("w!")

    local current_dir = vim.fn.expand("%:p:h") -- Get current file's directory
    local deprecated_folder = current_dir:gsub("(.+[\\/]service_definition[\\/]).*", "%1DEPRECATED\\")
    local move_command = "move \"" .. vim.api.nvim_buf_get_name(0) .. "\" \"" .. deprecated_folder .. "\""
    os.execute(move_command)

    local deprecated_file = deprecated_folder .. string.lower(service_name) .. "_v" .. versionInt .. ".xml"
    vim.cmd("silent! edit " .. deprecated_file)
    vim.api.nvim_win_set_cursor(0, { description_end_line + 3, 35 + #service_name })
end

local function deprecate(deprecated_info)
    deprecated_info = deprecated_info or ""
    local current_buffer_name = vim.api.nvim_buf_get_name(0)

    local version = current_buffer_name:match("_v(%d+)%.xml$")
    if not version then
        version = current_buffer_name:match("_V(%d+)%.xml$")
        if not version then
            print("Error: Unable to extract version number from file name.")
            return
        end
    end
    local old_version = version
    version = tonumber(version) + 1
    local versionString = getVersionString(version)

    local new_file_name = current_buffer_name:gsub("_v%d+%.xml$", "_v" .. versionString .. ".xml")

    local service_name = new_file_name.match(new_file_name, "s_(.-)_v%d+")
    if not service_name then
        service_name = new_file_name.match(new_file_name, "s_(.-)_V%d+")
        if not service_name then
            print("Error: cannot get service name")
            if new_file_name then
                print(" from (" .. new_file_name .. ")")
            end
            return
        end
    end
    local service_name_uppercase = service_name:upper()
    service_name_uppercase = "S_" .. service_name_uppercase
    local description_end_line = 0
    local id_line = 0
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    for i, line in ipairs(lines) do
        if line:find("<ID>") and line:find("</ID>") then
            id_line = i
        end
        if line:find("</Description>") then
            description_end_line = i
            break
        end
    end

    if description_end_line == 0 and id_line == 0 then
        print("</Description>  or </ID> not found.")
        return
    end

    lines[id_line] = "\t<ID>" .. service_name_uppercase .. "_V" .. versionString .. "</ID>"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_command("w!")

    local copy_command = "copy /Y \"" .. current_buffer_name .. "\" \"" .. new_file_name .. "\""
    os.execute(copy_command)

    lines[id_line] = "\t<ID>" .. service_name_uppercase .. "_V" .. old_version .. "</ID>"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_command("w!")

    addDeprecatedInfo(deprecated_info);
end

vim.api.nvim_create_user_command("Deprecate", function(_)
    deprecate()
end, { desc = "Deprecat service" })


vim.api.nvim_create_user_command("AddDeprecated", function(_)
    addDeprecatedInfo()
end, { desc = "Add deprecated info" })

vim.keymap.set('v', '<leader>sid', function(_)
    Get_And_Match_TextIDs()
end, { noremap = true, desc = "Get TextID values" })

vim.keymap.set('v', '<leader>id', function(_)
    Match_TextIDs()
end, { noremap = true, desc = "Get ids values" })

local getEnvDirectory = function()
    local current_dir = vim.fn.getcwd()
    local env_dir = current_dir:match("(D:\\src\\.-\\env\\)")
    if (not env_dir) then
        env_dir = "D:\\src\\develop\\env\\"
    end
    return env_dir
end

local getTextForTextIDs = function(ids)
    local filename = getEnvDirectory()
    filename = filename .. "en.txt"

    local file = io.open(filename, "r")

    if not file then
        vim.print("Could not open file: " .. filename)
        return ""
    end

    local matches = {}
    local addLine = false
    for line in file:lines() do
        local id = line:match("^(%d+)")
        if not id then
            if addLine then
                if addLine then
                    table.insert(matches, line)
                    table.insert(matches, "")
                    addLine = false
                end
            end
        else
            id = tonumber(id)
            if ids[id] then
                table.insert(matches, line)
                addLine = true
            end
        end
    end

    file:close()
    return matches
end

function Get_And_Match_TextIDs()
    local idSet = {}
    local selectedText = GetSelectedText()
    local pattern = 'TextID="(%d+)"'

    for line in string.gmatch(selectedText, "([^\n]*)\n?") do
        local id = line:match(pattern)
        if id then
            idSet[tonumber(id)] = true
        end
    end
    local matches = getTextForTextIDs(idSet)
    if matches then
        OpenFloatingWindow(matches)
    else
        vim.print("No ids found")
    end
end

function Match_TextIDs()
    local idSet = {}
    local selectedText = GetSelectedText()
    for line in string.gmatch(selectedText, "([^\n]*)\n?") do
        local accumulated_number = ""
        for char in line:gmatch(".") do
            if char:match("%d") then
                accumulated_number = accumulated_number .. char
            else
                break
            end
        end
        local id = tonumber(accumulated_number)
        if id then
            idSet[id] = true
        else
            vim.print("Error: Invalid ID found: " .. line)
        end
    end
    local matches = getTextForTextIDs(idSet)
    if matches then
        OpenFloatingWindow(matches)
    else
        vim.print("No ids found")
    end
end

function CreateTemplate(task, codeReviewers, description)
    local task_id = string.match(task, "TaskID%-%d+")
    return task .. "\n\n" .. description .. "\n\n" .. "**COMMIT-ID:" .. task_id .. "**CODEREVIEW:" .. codeReviewers
end

local function parse_input(input)
    local objects = {}
    local current_object = {}

    for line in input:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- Trim leading and trailing whitespace
        if line:find("id") then
            if next(current_object) then
                table.insert(objects, current_object)         -- Save the current object
            end
            current_object = { id = line:match("id%s+(.+)") } -- Extract ID
        elseif line:find("description") then
            local description = line:match("description%s+(.+)")
            if description then
                current_object.description = description -- Extract Description
            end
        end
    end

    -- Insert the last object if it exists
    if next(current_object) then
        table.insert(objects, current_object)
    end

    return objects
end

function SCommit()
    local tasks = Run_windows_command("GetTasks")
    local _tasks = parse_input(tasks)
    Custom_picker_id_description(_tasks, "Task picker", function(task)
        Input_from_file("Write and save the description for the commit:", function(description)
            local commit_message = CreateTemplate(task, codeReviewers, description)
        end)
    end)
end

vim.api.nvim_create_user_command('SCommit', SCommit, {})

local function get_xml_differences(file1_path, file2_path)
    local function read_file(path)
        local file = io.open(path, "r")
        if not file then return nil end
        local content = file:read("*a")
        file:close()
        return content
    end

    local function extract_tag_content(content, tag)
        local pattern = "<%s>(.-)</%s>"
        return content:match(string.format(pattern, tag, tag))
    end

    local function get_lines_and_fields(content)
        local lines = {}
        for line in content:gmatch("[^\r\n]+") do
            local fieldname = line:match('FieldName="([^"]+)"')
            if fieldname then
                lines[#lines + 1] = {
                    content = line,
                    fieldname = fieldname
                }
            end
        end
        return lines
    end

    local content1 = read_file(file1_path)
    local content2 = read_file(file2_path)

    if not content1 or not content2 then
        return nil, "Error reading files"
    end

    local input1 = extract_tag_content(content1, "Input")
    local output1 = extract_tag_content(content1, "Output")
    local input2 = extract_tag_content(content2, "Input")
    local output2 = extract_tag_content(content2, "Output")

    local input1_lines = get_lines_and_fields(input1)
    local output1_lines = get_lines_and_fields(output1)
    local input2_lines = get_lines_and_fields(input2)
    local output2_lines = get_lines_and_fields(output2)

    local function compare_line_sets(lines1, lines2)
        local different_fields = {}
        local checked_fields = {}

        local function lines_different(line1, line2)
            return line1.content ~= line2.content
        end

        for _, line1 in ipairs(lines1) do
            for _, line2 in ipairs(lines2) do
                if line1.fieldname == line2.fieldname then
                    checked_fields[line1.fieldname] = true
                    if lines_different(line1, line2) then
                        table.insert(different_fields, line1.fieldname)
                    end
                end
            end
        end

        for _, line in ipairs(lines1) do
            if not checked_fields[line.fieldname] then
                table.insert(different_fields, line.fieldname)
            end
        end
        for _, line in ipairs(lines2) do
            if not checked_fields[line.fieldname] then
                table.insert(different_fields, line.fieldname)
            end
        end

        return different_fields
    end

    local input_differences = compare_line_sets(input1_lines, input2_lines)
    local output_differences = compare_line_sets(output1_lines, output2_lines)

    local all_differences = {}
    local seen = {}

    for _, fieldname in ipairs(input_differences) do
        if not seen[fieldname] then
            table.insert(all_differences, fieldname)
            seen[fieldname] = true
        end
    end

    for _, fieldname in ipairs(output_differences) do
        if not seen[fieldname] then
            table.insert(all_differences, fieldname)
            seen[fieldname] = true
        end
    end

    return all_differences
end

function CompareXMLFiles()
    local current_file = vim.fn.expand('%:p')
    local alternate_file = vim.fn.expand('#:p')

    if current_file == '' or alternate_file == '' then
        print("Error: Need two files to compare")
        return
    end

    local differences = get_xml_differences(current_file, alternate_file)

    if differences then
        if #differences == 0 then
            print("No differences found in field names")
        else
            print("Different fields:")
            for _, fieldname in ipairs(differences) do
                print("- " .. fieldname)
            end
        end
    else
        print("Error comparing files")
    end
end

local function concat_list(items)
    local count = #items
    if count == 0 then
        return ""
    elseif count == 1 then
        return items[1]
    else
        return table.concat(items, ", ", 1, count - 1) .. " and " .. items[count]
    end
end

local function DeprecateNew()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)

    local version = current_buffer_name:match("_v(%d+)%.xml$")
    if not version then
        version = current_buffer_name:match("_V(%d+)%.xml$")
        if not version then
            print("Error: Unable to extract version number from file name.")
            return
        end
    end

    version = tonumber(version) + 1
    local versionString = getVersionString(version)

    local new_file_name = current_buffer_name:gsub("_v%d+%.xml$", "_v" .. versionString .. ".xml")
    local changedFields = get_xml_differences(current_buffer_name, new_file_name)
    local plural = ""
    if #changedFields > 1 then
        plural = "s"
    end
    deprecate("Added " .. concat_list(changedFields) .. " field" .. plural .. ".");
end

vim.api.nvim_create_user_command('DeprecateNew', DeprecateNew, {})
