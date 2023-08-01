# Keybinds 
| Function | Keybind | Mode | Opts |
|----------------------|--------------|------|------|
|  vim.cmd.Gi |  &quot;&lt;leader&gt;gs&quot; | &quot;n&quot; |  |
|  mark.add_fil |  &quot;&lt;leader&gt;a&quot; | &quot;n&quot; |  |
|  ui.toggle_quick_men |  &quot;&lt;C-e&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(1) en |  &quot;&lt;C-h&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(2) en |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(3) en |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(4) en |  &quot;&lt;C-l&gt;&quot; | &quot;n&quot; |  |
|  function() vim.lsp.buf.definition() end |  &quot;gd&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.hover() end |  &quot;K&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.workspace_symbol() end |  &quot;&lt;leader&gt;vws&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.open_float() end |  &quot;&lt;leader&gt;vd&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.goto_next() end |  &quot;[d&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.goto_prev() end |  &quot;]d&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.code_action() end |  &quot;&lt;leader&gt;vca&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.references() end |  &quot;&lt;leader&gt;vrr&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.rename() end |  &quot;&lt;leader&gt;vrn&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.signature_help() end |  &quot;&lt;C-h&gt;&quot; | &quot;i&quot; |  opt |
|  builtin.find_files |  &#x27;&lt;leader&gt;pf&#x27; | &#x27;n&#x27; |  { |
|  builtin.find_files |  &#x27;&lt;leader&gt;pg&#x27; | &#x27;n&#x27; |  { |
|  function |  &#x27;&lt;leader&gt;ps&#x27; | &#x27;n&#x27; |  |
|  vim.cmd.UndotreeToggl |  &quot;&lt;leader&gt;u&quot; |  &quot;n&quot; |  |
|  vim.cmd.E |  &quot;&lt;leader&gt;pv&quot; | &quot;n&quot; |  |
|  &quot;:m &#x27;&gt;+1&lt;CR&gt;gv=gv |  &quot;J&quot; | &quot;v&quot; |  |
|  &quot;:m &#x27;&lt;-2&lt;CR&gt;gv=gv |  &quot;K&quot; | &quot;v&quot; |  |
|  &quot;mzJ`z |  &quot;J&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-d&gt;zz |  &quot;&lt;C-d&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-u&gt;zz |  &quot;&lt;C-u&gt;&quot; | &quot;n&quot; |  |
|  &quot;nzzzv |  &quot;n&quot; | &quot;n&quot; |  |
|  &quot;Nzzzv |  &quot;N&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;vwm&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;svwm&quot; | &quot;n&quot; |  |
|  [[&quot;_dP] |  &quot;&lt;leader&gt;p&quot; | &quot;x&quot; |  |
|  [[&quot;+y] |  &quot;&lt;leader&gt;y&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  [[&quot;+Y] |  &quot;&lt;leader&gt;Y&quot; | &quot;n&quot; |  |
|  [[&quot;_d] |  &quot;&lt;leader&gt;d&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  &quot;&lt;Esc&gt; |  &quot;&lt;C-c&gt;&quot; | &quot;i&quot; |  |
|  &quot;&lt;nop&gt; |  &quot;Q&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;silent !tmux neww tmux-sessionizer&lt;CR&gt; |  &quot;&lt;C-f&gt;&quot; | &quot;n&quot; |  |
|  vim.lsp.buf.forma |  &quot;&lt;leader&gt;f&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cnext&lt;CR&gt;zz |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cprev&lt;CR&gt;zz |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lnext&lt;CR&gt;zz |  &quot;&lt;leader&gt;k&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lprev&lt;CR&gt;zz |  &quot;&lt;leader&gt;j&quot; | &quot;n&quot; |  |
|  [[:%s/\&lt;&lt;C-r&gt;&lt;C-w&gt;\&gt;/&lt;C-r&gt;&lt;C-w&gt;/gI&lt;Left&gt;&lt;Left&gt;&lt;Left&gt;] |  &quot;&lt;leader&gt;s&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;!chmod +x %&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;x&quot; | &quot;n&quot; |  { silent = true  |
|  &quot;&lt;cmd&gt;e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua&lt;CR&gt; |  &quot;&lt;leader&gt;vpp&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;CellularAutomaton make_it_rain&lt;CR&gt; |  &quot;&lt;leader&gt;mr&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;&lt;leader&gt;&quot; | &quot;n&quot; |  |
|  vim.cmd.E |  &quot;&lt;leader&gt;pv&quot; | &quot;n&quot; |  |
|  &quot;:m &#x27;&gt;+1&lt;CR&gt;gv=gv |  &quot;J&quot; | &quot;v&quot; |  |
|  &quot;:m &#x27;&lt;-2&lt;CR&gt;gv=gv |  &quot;K&quot; | &quot;v&quot; |  |
|  &quot;mzJ`z |  &quot;J&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-d&gt;zz |  &quot;&lt;C-d&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-u&gt;zz |  &quot;&lt;C-u&gt;&quot; | &quot;n&quot; |  |
|  &quot;nzzzv |  &quot;n&quot; | &quot;n&quot; |  |
|  &quot;Nzzzv |  &quot;N&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;vwm&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;svwm&quot; | &quot;n&quot; |  |
|  [[&quot;_dP] |  &quot;&lt;leader&gt;p&quot; | &quot;x&quot; |  |
|  [[&quot;+y] |  &quot;&lt;leader&gt;y&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  [[&quot;+Y] |  &quot;&lt;leader&gt;Y&quot; | &quot;n&quot; |  |
|  [[&quot;_d] |  &quot;&lt;leader&gt;d&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  &quot;&lt;Esc&gt; |  &quot;&lt;C-c&gt;&quot; | &quot;i&quot; |  |
|  &quot;&lt;nop&gt; |  &quot;Q&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;silent !tmux neww tmux-sessionizer&lt;CR&gt; |  &quot;&lt;C-f&gt;&quot; | &quot;n&quot; |  |
|  vim.lsp.buf.forma |  &quot;&lt;leader&gt;f&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cnext&lt;CR&gt;zz |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cprev&lt;CR&gt;zz |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lnext&lt;CR&gt;zz |  &quot;&lt;leader&gt;k&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lprev&lt;CR&gt;zz |  &quot;&lt;leader&gt;j&quot; | &quot;n&quot; |  |
|  [[:%s/\&lt;&lt;C-r&gt;&lt;C-w&gt;\&gt;/&lt;C-r&gt;&lt;C-w&gt;/gI&lt;Left&gt;&lt;Left&gt;&lt;Left&gt;] |  &quot;&lt;leader&gt;s&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;!chmod +x %&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;x&quot; | &quot;n&quot; |  { silent = true  |
|  &quot;&lt;cmd&gt;e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua&lt;CR&gt; |  &quot;&lt;leader&gt;vpp&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;CellularAutomaton make_it_rain&lt;CR&gt; |  &quot;&lt;leader&gt;mr&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;&lt;leader&gt;&quot; | &quot;n&quot; |  |
|  mark.add_fil |  &quot;&lt;leader&gt;a&quot; | &quot;n&quot; |  |
|  ui.toggle_quick_men |  &quot;&lt;C-e&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(1) en |  &quot;&lt;C-h&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(2) en |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(3) en |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(4) en |  &quot;&lt;C-l&gt;&quot; | &quot;n&quot; |  |
|  vim.cmd.UndotreeToggl |  &quot;&lt;leader&gt;u&quot; |  &quot;n&quot; |  |
|  vim.cmd.Gi |  &quot;&lt;leader&gt;gs&quot; | &quot;n&quot; |  |
|  builtin.find_files |  &#x27;&lt;leader&gt;pf&#x27; | &#x27;n&#x27; |  { |
|  builtin.find_files |  &#x27;&lt;leader&gt;pg&#x27; | &#x27;n&#x27; |  { |
|  function |  &#x27;&lt;leader&gt;ps&#x27; | &#x27;n&#x27; |  |
|  vim.cmd.Gi |  &quot;&lt;leader&gt;gs&quot; | &quot;n&quot; |  |
|  mark.add_fil |  &quot;&lt;leader&gt;a&quot; | &quot;n&quot; |  |
|  ui.toggle_quick_men |  &quot;&lt;C-e&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(1) en |  &quot;&lt;C-h&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(2) en |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(3) en |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  function() ui.nav_file(4) en |  &quot;&lt;C-l&gt;&quot; | &quot;n&quot; |  |
|  function() vim.lsp.buf.definition() end |  &quot;gd&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.hover() end |  &quot;K&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.workspace_symbol() end |  &quot;&lt;leader&gt;vws&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.open_float() end |  &quot;&lt;leader&gt;vd&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.goto_next() end |  &quot;[d&quot; | &quot;n&quot; |  opt |
|  function() vim.diagnostic.goto_prev() end |  &quot;]d&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.code_action() end |  &quot;&lt;leader&gt;vca&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.references() end |  &quot;&lt;leader&gt;vrr&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.rename() end |  &quot;&lt;leader&gt;vrn&quot; | &quot;n&quot; |  opt |
|  function() vim.lsp.buf.signature_help() end |  &quot;&lt;C-h&gt;&quot; | &quot;i&quot; |  opt |
|  builtin.find_files |  &#x27;&lt;leader&gt;pf&#x27; | &#x27;n&#x27; |  { |
|  builtin.find_files |  &#x27;&lt;leader&gt;pg&#x27; | &#x27;n&#x27; |  { |
|  function |  &#x27;&lt;leader&gt;ps&#x27; | &#x27;n&#x27; |  |
|  vim.cmd.UndotreeToggl |  &quot;&lt;leader&gt;u&quot; |  &quot;n&quot; |  |
|  vim.cmd.E |  &quot;&lt;leader&gt;pv&quot; | &quot;n&quot; |  |
|  &quot;:m &#x27;&gt;+1&lt;CR&gt;gv=gv |  &quot;J&quot; | &quot;v&quot; |  |
|  &quot;:m &#x27;&lt;-2&lt;CR&gt;gv=gv |  &quot;K&quot; | &quot;v&quot; |  |
|  &quot;mzJ`z |  &quot;J&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-d&gt;zz |  &quot;&lt;C-d&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-u&gt;zz |  &quot;&lt;C-u&gt;&quot; | &quot;n&quot; |  |
|  &quot;nzzzv |  &quot;n&quot; | &quot;n&quot; |  |
|  &quot;Nzzzv |  &quot;N&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;vwm&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;svwm&quot; | &quot;n&quot; |  |
|  [[&quot;_dP] |  &quot;&lt;leader&gt;p&quot; | &quot;x&quot; |  |
|  [[&quot;+y] |  &quot;&lt;leader&gt;y&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  [[&quot;+Y] |  &quot;&lt;leader&gt;Y&quot; | &quot;n&quot; |  |
|  [[&quot;_d] |  &quot;&lt;leader&gt;d&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  &quot;&lt;Esc&gt; |  &quot;&lt;C-c&gt;&quot; | &quot;i&quot; |  |
|  &quot;&lt;nop&gt; |  &quot;Q&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;silent !tmux neww tmux-sessionizer&lt;CR&gt; |  &quot;&lt;C-f&gt;&quot; | &quot;n&quot; |  |
|  vim.lsp.buf.forma |  &quot;&lt;leader&gt;f&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cnext&lt;CR&gt;zz |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cprev&lt;CR&gt;zz |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lnext&lt;CR&gt;zz |  &quot;&lt;leader&gt;k&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lprev&lt;CR&gt;zz |  &quot;&lt;leader&gt;j&quot; | &quot;n&quot; |  |
|  [[:%s/\&lt;&lt;C-r&gt;&lt;C-w&gt;\&gt;/&lt;C-r&gt;&lt;C-w&gt;/gI&lt;Left&gt;&lt;Left&gt;&lt;Left&gt;] |  &quot;&lt;leader&gt;s&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;!chmod +x %&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;x&quot; | &quot;n&quot; |  { silent = true  |
|  &quot;&lt;cmd&gt;e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua&lt;CR&gt; |  &quot;&lt;leader&gt;vpp&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;CellularAutomaton make_it_rain&lt;CR&gt; |  &quot;&lt;leader&gt;mr&quot; | &quot;n&quot; |  |
|  function |  &quot;&lt;leader&gt;&lt;leader&gt;&quot; | &quot;n&quot; |  |
|  |  |  |  |