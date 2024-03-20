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

function OpenBufferDirectory()
    local buffer_dir = vim.fn.expand('%:p:h')
    local open_command
    if vim.fn.has('win32') == 1 then
        open_command = 'explorer "' .. buffer_dir .. '"'
    else
        open_command = 'xdg-open "' .. buffer_dir .. '" &'
    end

    vim.fn.system(open_command)
end

vim.keymap.set("n", "<leader><C-O>", function() OpenBufferDirectory() end, { desc = "Open Current Directory in explorer" })

--vim.keymap.set("sb", "a", "adds file to stage or unstage list", {--[[Adds file to stage or unstage list]]});
--vim.keymap.set("sb", "X", "resets changes to file", {--[[Resets changes to file]]});

--vim.keymap.set("sb", "a", "new file/dir", {--[[Crete new file or dir (ends in /)]]});
--vim.keymap.set("sb", "r", "rename", {--[[Rename]]});
--vim.keymap.set("sb", "<C-r>", "rename without initial name", {--[[Rename without initial name]]});
--vim.keymap.set("sb", "d", "delete", {--[[Delete]]});
--vim.keymap.set("sb", "x", "cut", {--[[Cut]]});
--vim.keymap.set("sb", "p", "paste", {--[[Paste]]});
--vim.keymap.set("sb", "c", "copy", {--[[Copy]]});
--vim.keymap.set("sb", "y", "copy filename", {--[[Copy filename]]});
--vim.keymap.set("sb", "Y", "copy filename with relative path", {--[[Copy filename with relative path]]});
--vim.keymap.set("sb", "g+y", "copy filename with absolute path", {--[[Copy filename with absolute path]]});
--vim.keymap.set("sb", "Tab", "open file but keepcursor on tree", {--[[Open file but keepcursor on tree]]});
--vim.keymap.set("sb", "<C-v>", "open file w/ vertical split", {--[[Open file with vertical split]]});
--vim.keymap.set("sb", "<C-h>", "open file w/ horizontal split", {--[[Open file with horizontal split]]});
