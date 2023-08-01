# Keybinds 
| Function | Keybind | Mode | Opts |
 |  vim.cmd.Gi |  "<leader>gs" | "n" |  |
 |  mark.add_fil |  "<leader>a" | "n" |  |
 |  ui.toggle_quick_men |  "<C-e>" | "n" |  |
 |  function() ui.nav_file(1) en |  "<C-h>" | "n" |  |
 |  function() ui.nav_file(2) en |  "<C-j>" | "n" |  |
 |  function() ui.nav_file(3) en |  "<C-k>" | "n" |  |
 |  function() ui.nav_file(4) en |  "<C-l>" | "n" |  |
 |  function() vim.lsp.buf.definition() end |  "gd" | "n" |  opt |
 |  function() vim.lsp.buf.hover() end |  "K" | "n" |  opt |
 |  function() vim.lsp.buf.workspace_symbol() end |  "<leader>vws" | "n" |  opt |
 |  function() vim.diagnostic.open_float() end |  "<leader>vd" | "n" |  opt |
 |  function() vim.diagnostic.goto_next() end |  "[d" | "n" |  opt |
 |  function() vim.diagnostic.goto_prev() end |  "]d" | "n" |  opt |
 |  function() vim.lsp.buf.code_action() end |  "<leader>vca" | "n" |  opt |
 |  function() vim.lsp.buf.references() end |  "<leader>vrr" | "n" |  opt |
 |  function() vim.lsp.buf.rename() end |  "<leader>vrn" | "n" |  opt |
 |  function() vim.lsp.buf.signature_help() end |  "<C-h>" | "i" |  opt |
 |  builtin.find_files |  '<leader>pf' | 'n' |  { |
 |  builtin.find_files |  '<leader>pg' | 'n' |  { |
 |  function |  '<leader>ps' | 'n' |  |
 |  vim.cmd.UndotreeToggl |  "<leader>u" |  "n" |  |
 |  vim.cmd.E |  "<leader>pv" | "n" |  |
 |  ":m '>+1<CR>gv=gv |  "J" | "v" |  |
 |  ":m '<-2<CR>gv=gv |  "K" | "v" |  |
 |  "mzJ`z |  "J" | "n" |  |
 |  "<C-d>zz |  "<C-d>" | "n" |  |
 |  "<C-u>zz |  "<C-u>" | "n" |  |
 |  "nzzzv |  "n" | "n" |  |
 |  "Nzzzv |  "N" | "n" |  |
 |  function |  "<leader>vwm" | "n" |  |
 |  function |  "<leader>svwm" | "n" |  |
 |  [["_dP] |  "<leader>p" | "x" |  |
 |  "<leader>y" |  "v"} | {"n" |  [["+y] |
 |  [["+Y] |  "<leader>Y" | "n" |  |
 |  "<leader>d" |  "v"} | {"n" |  [["_d] |
 |  "<Esc> |  "<C-c>" | "i" |  |
 |  "<nop> |  "Q" | "n" |  |
 |  "<cmd>silent !tmux neww tmux-sessionizer<CR> |  "<C-f>" | "n" |  |
 |  vim.lsp.buf.forma |  "<leader>f" | "n" |  |
 |  "<cmd>cnext<CR>zz |  "<C-k>" | "n" |  |
 |  "<cmd>cprev<CR>zz |  "<C-j>" | "n" |  |
 |  "<cmd>lnext<CR>zz |  "<leader>k" | "n" |  |
 |  "<cmd>lprev<CR>zz |  "<leader>j" | "n" |  |
 |  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>] |  "<leader>s" | "n" |  |
 |  "<cmd>!chmod +x %<CR>" |  "<leader>x" | "n" |  { silent = true  |
 |  "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR> |  "<leader>vpp" | "n" |  |
 |  "<cmd>CellularAutomaton make_it_rain<CR> |  "<leader>mr" | "n" |  |
 |  function |  "<leader><leader>" | "n" |  |
 |  vim.cmd.E |  "<leader>pv" | "n" |  |
 |  ":m '>+1<CR>gv=gv |  "J" | "v" |  |
 |  ":m '<-2<CR>gv=gv |  "K" | "v" |  |
 |  "mzJ`z |  "J" | "n" |  |
 |  "<C-d>zz |  "<C-d>" | "n" |  |
 |  "<C-u>zz |  "<C-u>" | "n" |  |
 |  "nzzzv |  "n" | "n" |  |
 |  "Nzzzv |  "N" | "n" |  |
 |  function |  "<leader>vwm" | "n" |  |
 |  function |  "<leader>svwm" | "n" |  |
 |  [["_dP] |  "<leader>p" | "x" |  |
 |  "<leader>y" |  "v"} | {"n" |  [["+y] |
 |  [["+Y] |  "<leader>Y" | "n" |  |
 |  "<leader>d" |  "v"} | {"n" |  [["_d] |
 |  "<Esc> |  "<C-c>" | "i" |  |
 |  "<nop> |  "Q" | "n" |  |
 |  "<cmd>silent !tmux neww tmux-sessionizer<CR> |  "<C-f>" | "n" |  |
 |  vim.lsp.buf.forma |  "<leader>f" | "n" |  |
 |  "<cmd>cnext<CR>zz |  "<C-k>" | "n" |  |
 |  "<cmd>cprev<CR>zz |  "<C-j>" | "n" |  |
 |  "<cmd>lnext<CR>zz |  "<leader>k" | "n" |  |
 |  "<cmd>lprev<CR>zz |  "<leader>j" | "n" |  |
 |  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>] |  "<leader>s" | "n" |  |
 |  "<cmd>!chmod +x %<CR>" |  "<leader>x" | "n" |  { silent = true  |
 |  "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR> |  "<leader>vpp" | "n" |  |
 |  "<cmd>CellularAutomaton make_it_rain<CR> |  "<leader>mr" | "n" |  |
 |  function |  "<leader><leader>" | "n" |  |
 |  mark.add_fil |  "<leader>a" | "n" |  |
 |  ui.toggle_quick_men |  "<C-e>" | "n" |  |
 |  function() ui.nav_file(1) en |  "<C-h>" | "n" |  |
 |  function() ui.nav_file(2) en |  "<C-j>" | "n" |  |
 |  function() ui.nav_file(3) en |  "<C-k>" | "n" |  |
 |  function() ui.nav_file(4) en |  "<C-l>" | "n" |  |
 |  vim.cmd.UndotreeToggl |  "<leader>u" |  "n" |  |
 |  vim.cmd.Gi |  "<leader>gs" | "n" |  |
 |  builtin.find_files |  '<leader>pf' | 'n' |  { |
 |  builtin.find_files |  '<leader>pg' | 'n' |  { |
 |  function |  '<leader>ps' | 'n' |  |
 |  vim.cmd.Gi |  "<leader>gs" | "n" |  |
 |  mark.add_fil |  "<leader>a" | "n" |  |
 |  ui.toggle_quick_men |  "<C-e>" | "n" |  |
 |  function() ui.nav_file(1) en |  "<C-h>" | "n" |  |
 |  function() ui.nav_file(2) en |  "<C-j>" | "n" |  |
 |  function() ui.nav_file(3) en |  "<C-k>" | "n" |  |
 |  function() ui.nav_file(4) en |  "<C-l>" | "n" |  |
 |  function() vim.lsp.buf.definition() end |  "gd" | "n" |  opt |
 |  function() vim.lsp.buf.hover() end |  "K" | "n" |  opt |
 |  function() vim.lsp.buf.workspace_symbol() end |  "<leader>vws" | "n" |  opt |
 |  function() vim.diagnostic.open_float() end |  "<leader>vd" | "n" |  opt |
 |  function() vim.diagnostic.goto_next() end |  "[d" | "n" |  opt |
 |  function() vim.diagnostic.goto_prev() end |  "]d" | "n" |  opt |
 |  function() vim.lsp.buf.code_action() end |  "<leader>vca" | "n" |  opt |
 |  function() vim.lsp.buf.references() end |  "<leader>vrr" | "n" |  opt |
 |  function() vim.lsp.buf.rename() end |  "<leader>vrn" | "n" |  opt |
 |  function() vim.lsp.buf.signature_help() end |  "<C-h>" | "i" |  opt |
 |  builtin.find_files |  '<leader>pf' | 'n' |  { |
 |  builtin.find_files |  '<leader>pg' | 'n' |  { |
 |  function |  '<leader>ps' | 'n' |  |
 |  vim.cmd.UndotreeToggl |  "<leader>u" |  "n" |  |
 |  vim.cmd.E |  "<leader>pv" | "n" |  |
 |  ":m '>+1<CR>gv=gv |  "J" | "v" |  |
 |  ":m '<-2<CR>gv=gv |  "K" | "v" |  |
 |  "mzJ`z |  "J" | "n" |  |
 |  "<C-d>zz |  "<C-d>" | "n" |  |
 |  "<C-u>zz |  "<C-u>" | "n" |  |
 |  "nzzzv |  "n" | "n" |  |
 |  "Nzzzv |  "N" | "n" |  |
 |  function |  "<leader>vwm" | "n" |  |
 |  function |  "<leader>svwm" | "n" |  |
 |  [["_dP] |  "<leader>p" | "x" |  |
 |  "<leader>y" |  "v"} | {"n" |  [["+y] |
 |  [["+Y] |  "<leader>Y" | "n" |  |
 |  "<leader>d" |  "v"} | {"n" |  [["_d] |
 |  "<Esc> |  "<C-c>" | "i" |  |
 |  "<nop> |  "Q" | "n" |  |
 |  "<cmd>silent !tmux neww tmux-sessionizer<CR> |  "<C-f>" | "n" |  |
 |  vim.lsp.buf.forma |  "<leader>f" | "n" |  |
 |  "<cmd>cnext<CR>zz |  "<C-k>" | "n" |  |
 |  "<cmd>cprev<CR>zz |  "<C-j>" | "n" |  |
 |  "<cmd>lnext<CR>zz |  "<leader>k" | "n" |  |
 |  "<cmd>lprev<CR>zz |  "<leader>j" | "n" |  |
 |  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>] |  "<leader>s" | "n" |  |
 |  "<cmd>!chmod +x %<CR>" |  "<leader>x" | "n" |  { silent = true  |
 |  "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR> |  "<leader>vpp" | "n" |  |
 |  "<cmd>CellularAutomaton make_it_rain<CR> |  "<leader>mr" | "n" |  |
 |  function |  "<leader><leader>" | "n" |  |
 |  |  |  |  |