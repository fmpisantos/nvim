--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open [P]roject [V]iew"});
vim.keymap.set("n", "n", "nzzzv", { desc = "Goto [N]ext occurence of search and centers it to the old cursor positon" });
vim.keymap.set("n", "N", "Nzzzv", { desc = "Goto previous occurence of search and centers it to the old cursor positon" });
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "[P]astes but saves old text in selection" });
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[Y]ank to clipboard" });
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "[Y]ank to clipboard" });
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "[D]eletes without copy" });
vim.keymap.set("n", "Q", "<nop>", { desc = "No operation" });
vim.keymap.set("n", "<leader>k", "<cmd>cnext<CR>zz", { desc = "Goto prev error" })
vim.keymap.set("n", "<F3>", "<cmd>cnext<CR>zz", { desc = "Goto prev error" })
vim.keymap.set("n", "<leader>j", "<cmd>cprev<CR>zz", { desc = "Goto next error" })
vim.keymap.set("n", "<S-F3>", "<cmd>cprev<CR>zz", { desc = "Goto next error" })
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
vim.keymap.set("n", "<C-->", "<C-o>", { noremap = true, silent = true, desc = "Go back" });
vim.keymap.set("n", "<C-_>", "<C-i>", { noremap = true, silent = true, desc = "Go forward" });
vim.api.nvim_set_keymap('n', '<leader>zi', ':lua ToggleFoldUnderCursor()<CR>', { noremap = true, silent = true })

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

vim.keymap.set("n", "<leader><C-O>", function() OpenBufferDirectory() end,
    { desc = "Open Current Directory in explorer" })
vim.cmd([[command! Open :lua OpenBufferDirectory()]])
vim.cmd([[command! Open :lua LauchBudder()]])


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

vim.api.nvim_create_user_command('Location', GetCurrentLocation, {})
vim.api.nvim_create_user_command('FullLocation', GetCurrentLocationFull, {})
