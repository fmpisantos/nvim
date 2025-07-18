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

    local isService = true;

    local current_dir = vim.fn.expand("%:p:h") -- Get current file's directory

    local deprecated_folder, count = current_dir:gsub("(.+[\\/]service_definition[\\/]).*", "%1DEPRECATED\\")
    if count == 0 then
        isService = false;
        deprecated_folder, count = current_dir:gsub("(.+[\\/]notification_definition[\\/]).*",
            "%1DEPRECATED\\AutoTasks\\")
    end

    if count == 0 then
        error("Neither 'service_definition' nor 'notification_definition' found in the path.")
    end
    local finished = false
    local nextLineIsEmpty = false
    for i, line in ipairs(lines) do
        if finished then
            nextLineIsEmpty = trim(line) ~= ""
            break
        end
        if not isService then
            lines[i] = line:gsub("%.%.%/SIHOT%.xsd", "../../SIHOT.xsd")
        end
        if line:find("<ID>") and line:find("</ID>") then
            id_line = i
            service_name, versionInt = string.match(line, "<ID>(.-)_V(%d%d%d)</ID>");
        end
        if line:find("</Description>") then
            description_end_line = i;
            finished = true
        end
    end

    if id_line == 0 or description_end_line == 0 then
        print("Error: Unable to locate <ID>...</ID>  or </Description> in current buffer.");
        return
    end

    local version_string = getVersionString(tonumber(versionInt) + 1);
    local deprecated_section = "\t<Deprecated>\n\t\t<Reference ";
    if isService then
        deprecated_section = deprecated_section .. "Service"
    else
        deprecated_section = deprecated_section .. "Notification"
    end
    deprecated_section = deprecated_section .. "=\"" ..
        service_name .. "_V" .. version_string .. "\" Text=\"" .. deprecated_info .. "\"/>\n\t</Deprecated>"

    local replacement_lines = { "" }

    for line in deprecated_section:gmatch("[^\r\n]+") do
        table.insert(replacement_lines, line)
    end

    if nextLineIsEmpty then
        table.insert(replacement_lines, "")
    end

    vim.api.nvim_buf_set_option(0, "modifiable", true)
    if not isService then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end

    vim.api.nvim_buf_set_lines(0, description_end_line, description_end_line, false, replacement_lines)
    vim.api.nvim_command("w!")
    local move_command = "move \"" .. vim.api.nvim_buf_get_name(0) .. "\" \"" .. deprecated_folder .. "\""
    os.execute(move_command)

    local deprecated_file = deprecated_folder .. string.lower(service_name) .. "_v" .. versionInt .. ".xml"
    vim.cmd("silent! edit " .. deprecated_file)
    local offset = 35;
    if not isService then
        offset = offset + 5
    end
    vim.api.nvim_win_set_cursor(0, { description_end_line + 3, offset + #service_name })
end

local function gotoDeprecatedFile()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local service_name
    local versionInt
    local description_end_line

    local isService = true
    local current_dir = vim.fn.expand("%:p:h")

    local deprecated_folder, count = current_dir:gsub("(.+[\\/]service_definition[\\/]).*", "%1DEPRECATED\\")
    if count == 0 then
        isService = false
        deprecated_folder, count = current_dir:gsub("(.+[\\/]notification_definition[\\/]).*",
            "%1DEPRECATED\\AutoTasks\\")
    end

    if count == 0 then
        error("Neither 'service_definition' nor 'notification_definition' found in the path.")
    end

    local finished = false
    for i, line in ipairs(lines) do
        if finished then break end
        if not isService then
            lines[i] = line:gsub("%.%.%/SIHOT%.xsd", "../../SIHOT.xsd")
        end
        if line:find("<ID>") and line:find("</ID>") then
            service_name, versionInt = string.match(line, "<ID>(.-)_V(%d%d%d)</ID>")
            versionInt = tonumber(versionInt)
        end
        if line:find("</Description>") then
            description_end_line = i
            finished = true
        end
    end

    if not service_name or not versionInt then
        print("Could not extract service name or version.")
        return
    end

    local file_name = string.lower(service_name) .. "_v" .. string.format("%03d", versionInt) .. ".xml"
    local deprecated_file = deprecated_folder .. file_name

    if not vim.loop.fs_stat(deprecated_file) then
        versionInt = versionInt - 1
        file_name = string.lower(service_name) .. "_v" .. string.format("%03d", versionInt) .. ".xml"
        deprecated_file = deprecated_folder .. file_name

        if not vim.loop.fs_stat(deprecated_file) then
            print("Deprecated file does not exist for current or previous version.")
            return
        end
    end

    vim.cmd("silent! edit " .. deprecated_file)

    local offset = isService and 35 or 40
    vim.api.nvim_win_set_cursor(0, { description_end_line + 3, offset + #service_name })
end

local function _deprecate(deprecated_info, createNew)
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

    if createNew then
        lines[id_line] = "\t<ID>" .. service_name_uppercase .. "_V" .. versionString .. "</ID>"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_command("w!")
        local copy_command = "copy /Y \"" .. current_buffer_name .. "\" \"" .. new_file_name .. "\""
        os.execute(copy_command)
    end

    lines[id_line] = "\t<ID>" .. service_name_uppercase .. "_V" .. old_version .. "</ID>"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_command("w!")

    addDeprecatedInfo(deprecated_info);
end


local function deprecate(deprecated_info)
    local createNew = true
    if deprecated_info then
        createNew = false
    else
        deprecated_info = ""
    end
    _deprecate(deprecated_info, createNew)
end

vim.api.nvim_create_user_command("Deprecate", function(_)
    deprecate()
end, { desc = "Deprecat service" })

vim.api.nvim_create_user_command("GotoDeprecated", function(_)
    gotoDeprecatedFile()
end, { desc = "Goto deprecated file" })

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

    local names = {}

    local function get_lines_and_fields(content, category)
        local lines = {}
        for line in content:gmatch("[^\r\n]+") do
            local fieldname = line:match('FieldName="([^"]+)"')
            local alias = line:match('Alias="([^"]+)"') or "" -- Pode estar ausente
            local name = line:match(' Name="([^"]+)"')        -- Pode estar ausente
            if fieldname then
                -- Criar um identificador único ignorando espaços
                local identifier = category .. "|" .. alias .. "|" .. fieldname
                identifier = identifier:gsub("%s+", "")
                lines[identifier] = line:gsub("%s+", "") -- Remover espaços do conteúdo antes de comparar
                if name ~= nil and name ~= '' then
                    names[identifier] = name
                else
                    names[identifier] = fieldname
                end
            end
        end
        return lines
    end

    local _content1 = read_file(file1_path)
    local _content2 = read_file(file2_path)
    if not _content1 or not _content2 then
        return nil, "Error reading files"
    end

    local input1 = extract_tag_content(_content1, "Input") or ""
    local output1 = extract_tag_content(_content1, "Output") or ""
    local input2 = extract_tag_content(_content2, "Input") or ""
    local output2 = extract_tag_content(_content2, "Output") or ""

    local input1_lines = get_lines_and_fields(input1, "Input")
    local output1_lines = get_lines_and_fields(output1, "Output")
    local input2_lines = get_lines_and_fields(input2, "Input")
    local output2_lines = get_lines_and_fields(output2, "Output")

    local function compare_line_sets(lines1, lines2)
        local different_fields = {}
        local seen = {}

        for identifier, content1 in pairs(lines1) do
            if lines2[identifier] then
                if content1 ~= lines2[identifier] then
                    table.insert(different_fields, names[identifier]) -- Extrai apenas o FieldName
                end
            else
                table.insert(different_fields, names[identifier])
            end
            seen[identifier] = true
        end

        for identifier, _ in pairs(lines2) do
            if not seen[identifier] then
                table.insert(different_fields, names[identifier])
            end
        end

        return different_fields
    end

    local input_differences = compare_line_sets(input1_lines, input2_lines)
    local output_differences = compare_line_sets(output1_lines, output2_lines)

    local all_differences = {}
    local seen_fields = {}

    for _, fieldname in ipairs(input_differences) do
        if not seen_fields[fieldname] then
            table.insert(all_differences, fieldname)
            seen_fields[fieldname] = true
        end
    end
    for _, fieldname in ipairs(output_differences) do
        if not seen_fields[fieldname] then
            table.insert(all_differences, fieldname)
            seen_fields[fieldname] = true
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

local function search_file_by_name(filename)
    local current_path = vim.fn.expand('%:p:h')

    local service_pos = string.find(current_path, "service_definition")
    local notification_pos = string.find(current_path, "notification_definition")

    if not (service_pos or notification_pos) then
        print("Error: This function can only search in service_definition or notification_definition directories")
        return
    end

    local base_path
    if service_pos then
        base_path = string.sub(current_path, 1, service_pos + #"service_definition" - 1)
    elseif notification_pos then
        base_path = string.sub(current_path, 1, notification_pos + #"notification_definition" - 1)
    end

    local direct_pattern = base_path .. '/' .. filename
    local file_path = vim.fn.glob(direct_pattern)

    if file_path == "" then
        local recursive_pattern = base_path .. '/**/' .. filename
        file_path = vim.fn.glob(recursive_pattern)
    else
    end

    if file_path == "" then
        print("File not found!")
    else
        -- print("Found file at: " .. file_path)
        return file_path;
    end
end

local function DeprecateNew(service_name)
    local current_buffer_name = vim.api.nvim_buf_get_name(0)

    if not service_name then
        service_name = current_buffer_name.match(current_buffer_name, "s_(.-)_v%d+")
        if not service_name then
            service_name = current_buffer_name.match(current_buffer_name, "s_(.-)_V%d+")
            if not service_name then
                print("Error: cannot get service name")
                if current_buffer_name then
                    print(" from (" .. current_buffer_name .. ")")
                end
                return
            end
        end
    end

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

    local new_file_name = search_file_by_name("s_" .. service_name .. "_v" .. versionString .. ".xml");
    local changedFields = get_xml_differences(current_buffer_name, new_file_name)
    local plural = ""
    if #changedFields > 1 then
        plural = "s"
    end
    deprecate("Added " .. concat_list(changedFields) .. " field" .. plural .. ".");
end

vim.api.nvim_create_user_command('DeprecateNew', DeprecateNew, {})

local function AddToInventory()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)

    -- Determine if we're dealing with a service or notification
    local is_service = current_buffer_name:match("service_definition") ~= nil
    local is_notification = current_buffer_name:match("notification_definition") ~= nil

    if not (is_service or is_notification) then
        print("Error: Current file is neither a service nor a notification definition")
        return
    end

    -- Extract the name based on file type
    local item_name
    if is_service then
        item_name = current_buffer_name:match("s_(.-).xml")
    else
        item_name = current_buffer_name:match("s_(.-).xml")
    end

    if not item_name then
        print("Error: Could not extract name from the current file")
        return
    end

    -- Determine the inventory file path and tag based on file type
    local inventory_file_path
    local tag_type
    local id_prefix

    if is_service then
        tag_type = "ServiceID"
        id_prefix = "S_"
        inventory_file_path = vim.fn.fnamemodify(current_buffer_name, ":p:h:h:h") ..
            "\\service_inventory\\SihotServices01.xml"
    else
        tag_type = "NotificationID"
        id_prefix = "S_"
        inventory_file_path = vim.fn.fnamemodify(current_buffer_name, ":p:h:h:h") ..
            "\\notification_inventory\\s_push_notifications_global.xml"
    end

    -- Create the tag content
    local id_tag = "<" .. tag_type .. ">" .. id_prefix .. item_name:upper() .. "</" .. tag_type .. ">"

    -- Read the inventory file
    local file = io.open(inventory_file_path, "r")
    if not file then
        print("Error: Unable to open inventory file at " .. inventory_file_path)
        return
    end

    -- Store all lines from the file
    local lines = {}
    local id_found = false
    local insert_index = nil
    local closing_tag = is_service and "</ServiceInventoryDefinition>" or "</NotificationInventoryDefinition>"

    for line in file:lines() do
        -- Check if a matching ID already exists
        local pattern = "    <" .. tag_type .. ">" .. id_prefix .. item_name:upper() .. "_V%d+</" .. tag_type .. ">"
        if line:match(pattern) then
            id_found = true
        end

        -- Find where the closing tag is to insert before it
        if line:match(closing_tag) then
            insert_index = #lines + 1
        end

        table.insert(lines, line)
    end
    file:close()

    -- If the ID doesn't exist, insert it before the closing tag
    if not id_found and insert_index then
        table.insert(lines, insert_index, "    " .. id_tag)
    end

    -- Write back the updated content
    file = io.open(inventory_file_path, "w")
    if not file then
        print("Error: Unable to write to inventory file")
        return
    end

    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()

    -- print("Updated inventory file with " .. tag_type .. ":", id_tag)
end

vim.api.nvim_create_user_command('AddInv', AddToInventory, {})

local function GitDeprecation()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false);
    local versionInt;
    local service_name;
    local current_dir = vim.fn.expand("%:p:h")

    local deprecated_folder, count = current_dir:gsub("(.+[\\/]service_definition[\\/]).*", "%1DEPRECATED\\")
    if count == 0 then
        deprecated_folder, count = current_dir:gsub("(.+[\\/]notification_definition[\\/]).*",
            "%1DEPRECATED\\AutoTasks\\")
    end

    if count == 0 then
        error("Neither 'service_definition' nor 'notification_definition' found in the path.")
    end

    for i, line in ipairs(lines) do
        if line:find("<ID>") and line:find("</ID>") then
            service_name, versionInt = string.match(line, "<ID>(.-)_V(%d%d%d)</ID>");
            lines[i] = line:gsub(getVersionString(tonumber(versionInt)), getVersionString(tonumber(versionInt) + 1))
        end
        if line:find("</Description>") then
            break;
        end
    end

    local original_buf = vim.api.nvim_get_current_buf()
    local current_name = vim.api.nvim_buf_get_name(0)

    local new_name = current_name:gsub(getVersionString(tonumber(versionInt)),
        getVersionString(tonumber(versionInt) + 1))

    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, new_name)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_set_current_buf(buf)
    vim.cmd("write")

    AddToInventory();

    -- Use `git checkout` to discard changes for the current file
    vim.api.nvim_set_current_buf(original_buf);
    vim.fn.system({ 'git', 'checkout', '--', current_name });
    vim.api.nvim_command('silent! e');
    vim.api.nvim_command('w!');

    local move_command = "move \"" .. vim.api.nvim_buf_get_name(0) .. "\" \"" .. deprecated_folder .. "\""
    os.execute(move_command);

    local deprecated_file = deprecated_folder .. string.lower(service_name) .. "_v" .. versionInt .. ".xml"
    vim.cmd("silent! edit " .. deprecated_file)

    DeprecateNew();
end

vim.api.nvim_create_user_command('DeprecateGitChanges', GitDeprecation, {})

local function NewService()
    local api = vim.api

    local filename = vim.fn.expand("%:t:r"):upper()

    local content = {
        '<?xml version="1.0" encoding="ISO-8859-1"?>',
        '<ServiceDefinition  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../SIHOT.xsd">',
        '    <ID>' .. filename .. '</ID>',
        '',
        '    <Description>',
        '        <Language LanguageCode="EN" Text=""/>	',
        '    </Description>',
        '',
        '    <WSDLDocumentation>',
        '        <![CDATA[',
        '        ### General',
        '        ',
        '        This service ',
        '',
        '        ### Input',
        '',
        '        ### Output',
        '',
        '        ]]>',
        '    </WSDLDocumentation>',
        '',
        '    <BO Class="BO_PERSON"		Alias="Person"/>',
        '',
        '    <Input >',
        '        <Tree>',
        '            <Node Alias="" 		Mode="loadFromDB">',
        '                <Column Alias=""	FieldName="" Compulsory="true"	Name=""/>',
        '            </Node>',
        '        </Tree>',
        '    </Input>',
        '',
        '    <Output>',
        '        <Tree>',
        '            <Node Alias="" Name="">',
        '                <Column Alias="" FieldName="" />',
        '            </Node>',
        '        </Tree>',
        '    </Output>',
        '</ServiceDefinition>'
    }

    api.nvim_buf_set_lines(0, 0, -1, false, content)

    vim.cmd("write")

    AddToInventory();
end

vim.api.nvim_create_user_command('NewService', NewService, {})
