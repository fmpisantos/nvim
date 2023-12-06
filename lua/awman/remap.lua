vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

--vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
--vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

vim.keymap.set("n", "gf", function()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<CR>"
  else
    return "gf"
  end
end, { noremap = false, expr = true })

vim.keymap.set("n", "gd", function()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<CR>"
  else
    return "gf"
  end
end, { noremap = false, expr = true })

vim.keymap.set("n","<leader>bm",function() require("bookmarks").bookmark_toggle() end, {--[[ add or remove bookmark at current line]]}) 
vim.keymap.set("n","<leader>bi",function() require("bookmarks").bookmark_toggle() end, {--[[ add or remove bookmark at current line]]}) 
vim.keymap.set("n","<leader>bme",function() require("bookmarks").bookmark_ann() end, {--[[add or edit mark annotation at current line]]}) 
vim.keymap.set("n","<leader>be",function() require("bookmarks").bookmark_ann() end, {--[[add or edit mark annotation at current line]]}) 
vim.keymap.set("n","<leader>bc",function() require("bookmarks").bookmark_clean() end, {--[[clean all marks in local buffer]]}) 
vim.keymap.set("n","<leader>bn",function() require("bookmarks").bookmark_next() end, {--[[jump to next mark in local buffer]]}) 
vim.keymap.set("n","<leader>bp",function() require("bookmarks").bookmark_prev() end, {--[[jump to previous mark in local buffer]]}) 
vim.keymap.set("n","<leader>bl",function() require("bookmarks").bookmark_list() end, {--[[show marked file list in quickfix window]]}) 

vim.keymap.set("n", "<S-Tab>", "<<hhhh");
vim.keymap.set("n", "<leader><Tab>", ">>llll");
vim.keymap.set("v", "<S-Tab>", "<gv");
vim.keymap.set("v", "<Tab>", ">gv");

vim.keymap.set("n", "<M-j>", ":m+<CR>==");
vim.keymap.set("n", "<M-k>", ":m-2<CR>==");

vim.keymap.set("n", "<leader>gs", vim.cmd.Git, {--[[Git commit]]});
vim.keymap.set("n","<leader>gd", "<cmd>:Gdiff<CR>", {--[[Git difference]]});
vim.keymap.set("n", "<leader>gh", "<cmd>diffget //2<CR>", {--[[Use left]]});
vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>", {--[[Use left]]});
vim.keymap.set("n", "<leader>gl", "<cmd>diffget //3<CR>", {--[[Use righ]]});
vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>", {--[[Use righ]]});
vim.keymap.set("n","<leader>gc", "<cmd>:Git commit<CR>", {--[[Git commit]]}); 
vim.keymap.set("n", "<leader>gp", "<cmd>:Git push -u origin<CR>", {--[[Git commit]]});

