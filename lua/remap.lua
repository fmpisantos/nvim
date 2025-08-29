function ToggleFoldUnderCursor()
    local cursor_line = vim.fn.line('.')
    if vim.fn.foldclosed(cursor_line) ~= -1 then
        vim.cmd('normal! zO')
    else
        vim.cmd('normal! zC')
    end
end

function LaunchBuffer()
    local buffer_dir = vim.fn.expand('%:p')
    local open_command

    local os_name = vim.loop.os_uname().sysname
    if os_name == 'Windows_NT' then
        open_command = 'explorer "' .. buffer_dir .. '"'
    elseif os_name == 'Darwin' then
        open_command = 'open "' .. buffer_dir .. '"'
    else
        open_command = 'xdg-open "' .. buffer_dir .. '" &'
    end

    vim.fn.system(open_command)
end

function OpenBufferDirectory()
    local buffer_dir = vim.fn.expand('%:p:h')
    local open_command

    local os_name = vim.loop.os_uname().sysname
    if os_name == 'Windows_NT' then
        open_command = 'explorer "' .. buffer_dir .. '"'
    elseif os_name == 'Darwin' then
        open_command = 'open "' .. buffer_dir .. '"'
    else
        open_command = 'xdg-open "' .. buffer_dir .. '" &'
    end

    vim.fn.system(open_command)
end

function GetCurrentLocation()
    local location = vim.fn.expand("%") .. ":" .. vim.fn.line(".")
    print(location)
    vim.fn.setreg("+", location)
end

function GetCurrentLocationFull()
    local location = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
    print(location)
    vim.fn.setreg("+", location)
end

vim.keymap.set("n", "n", "nzzzv", { desc = "Goto [N]ext occurence of search and centers it to the old cursor positon" });
vim.keymap.set("n", "N", "Nzzzv", { desc = "Goto previous occurence of search and centers it to the old cursor positon" });
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "[Y]ank to clipboard" });
vim.keymap.set({ "n", "v", "x" }, "<leader>Y", '"+Y', { desc = "[Y]ank to clipboard" });
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "[P]aste from clipboard" });
vim.keymap.set({ "n", "v", "x" }, "<leader>P", '"+P', { desc = "[P]aste from clipboard" });
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d', { desc = "[D]elete to clipboard" });
vim.keymap.set("n", "Q", "<nop>", { desc = "No operation" });
vim.keymap.set("n", "<S-Tab>", "<<hhhh", { desc = "Remove tab" });
vim.keymap.set("n", "<leader><Tab>", ">>llll", { desc = "Add tab" });
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Remove tab for selected lines" });
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Add tab to selected lines" });
vim.keymap.set("n", "<M-j>", ":m+<CR>==", { desc = "Switch present line with line above" });
vim.keymap.set("n", "<M-k>", ":m-2<CR>==", { desc = "Switch present line with line bellow" });
vim.keymap.set("n", "zZ", "zszH", { desc = "Center line" });
vim.keymap.set("n", "<M-.>", "<C-W>5<", { desc = "Decrease window width" });
vim.keymap.set("n", "<M-,>", "<C-W>5>", { desc = "Increase window width" });
vim.keymap.set("n", "<M-Up>", "<C-W>5-", { desc = "Decrease window width" });
vim.keymap.set("n", "<M-Down>", "<C-W>5+", { desc = "Increase window width" });
vim.api.nvim_set_keymap('n', '<leader>zi', ':lua ToggleFoldUnderCursor()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader><C-O>", function() OpenBufferDirectory() end,
    { desc = "Open Current Directory in explorer" })

vim.cmd([[command! OpenDirectory :lua OpenBufferDirectory()]])
vim.cmd([[command! Open :lua LaunchBuffer()]])

vim.keymap.set("n", "zZ", "zszH", { desc = "Center line" });

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('t', "<esc>", "<C-\\><C-n>");

vim.keymap.set('n', '<leader>te',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity = vim.diagnostic.severity.ERROR })<CR>',
    { noremap = true, silent = true, desc = "[T]rouble [E]rrors" })
vim.keymap.set('n', '<leader>tt', '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true })<CR>',
    { noremap = true, silent = true, desc = "[T]rouble [T]oggle" })
vim.keymap.set('n', '<leader>tde',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true, desc = "[D]ocument [E]rrors" })
vim.keymap.set('n', '<leader>td',
    '<cmd>lua vim.diagnostic.setqflist({ open = true, severity_sort = true, bufnr = 0 })<CR>',
    { noremap = true, silent = true, desc = "[D]ocument [T]oggle" })

vim.keymap.set("n", "<leader>l", ":lua show_current_line_popup()<cr>",
    { noremap = true, silent = true, desc = "show current line in popup" });

vim.keymap.set('n', '<leader>qf', ':lua FilterQFListToFile()<cr>',
    { noremap = true, silent = true, desc = "[Q]uickFixList [F]ilter" })

vim.api.nvim_create_user_command('Location', GetCurrentLocation, {})
vim.api.nvim_create_user_command('FullLocation', GetCurrentLocationFull, {})

local function g_to_qf(pattern)
    local start_pos  = vim.fn.getpos("'<")
    local end_pos    = vim.fn.getpos("'>")
    local bufnr      = vim.api.nvim_get_current_buf()

    local start_line = start_pos[2]
    local end_line   = end_pos[2]

    local qf_entries = {}
    for lnum = start_line, end_line do
        local line = vim.fn.getline(lnum)
        local col = string.find(line, pattern)
        if col then
            table.insert(qf_entries, {
                bufnr = bufnr,
                lnum = lnum,
                col = col,
                text = line,
            })
        end
    end

    if #qf_entries > 0 then
        vim.fn.setqflist(qf_entries, "r")
        vim.cmd("copen")
    else
        print("No matches")
    end
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = ":",
    callback = function()
        local cmd = vim.fn.getcmdline()
        local pat = cmd:match("^'<,'>g/(.+)/?$")
        if pat then
            g_to_qf(pat)
        end
    end,
})

local function translate_to_english()
    local selected_text = getVisualSelection()

    if selected_text == "" then
        print("No text selected")
        return
    end

    local api_url = "https://api-free.deepl.com/v2/translate"
    local deepl_key = os.getenv("DEEPL_API_KEY")
    if not deepl_key then
        print("Please set the DEEPL_API_KEY environment variable")
        return
    end
    local target_lang = "EN"

    local response = vim.fn.system({
        "curl", "-s", "-X", "POST", api_url,
        "-d", "auth_key=" .. deepl_key,
        "--ssl-no-revoke", -- Add this flag to fix Windows SSL issue
        "-d", "text=" .. vim.fn.shellescape(selected_text),
        "-d", "target_lang=" .. target_lang,
    })

    local success, result = pcall(vim.fn.json_decode, response)
    if not success or not result or not result.translations or result.translations[1].text == "" then
        vim.print(vim.inspect(result))
        vim.print(vim.inspect(response))
        print("Translation failed")
        return
    end

    OpenFloatingWindow({ result.translations[1].text })
end

vim.api.nvim_create_user_command(
    "Translate",
    translate_to_english,
    { range = true, desc = "Translate selected lines to English" }
)

vim.keymap.set('n', "<C-c>", "<cmd>let @+ = expand(\"%:p\")<CR>", { desc = "Copy filepath to clipboard" });
vim.keymap.set('n', "<leader>c", "<cmd>let @+ = expand(\"%:p\")<CR>", { desc = "Copy filepath to clipboard" });
