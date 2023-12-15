# Keybinds 
| Function | Keybind | Mode | Opts |
|----------------------|--------------|------|------|
| :Gdiff | dv | n |  |
| &lt;cmd&gt;diffget //2&lt;CR&gt; | gh | n | Get left in conflict (in :Gdiff) |
| &lt;cmd&gt;diffget //3&lt;CR&gt; | gl | n | Get right in conflict (in :Gdiff) |
|  vim.cmd.Ex |  &quot;&lt;leader&gt;pv&quot; | &quot;n&quot; |  |
|  &quot;:m &#x27;&gt;+1&lt;CR&gt;gv=gv&quot; |  &quot;J&quot; | &quot;v&quot; |  |
|  &quot;:m &#x27;&lt;-2&lt;CR&gt;gv=gv&quot; |  &quot;K&quot; | &quot;v&quot; |  |
|  &quot;&lt;C-d&gt;zz&quot; |  &quot;&lt;C-d&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;C-u&gt;zz&quot; |  &quot;&lt;C-u&gt;&quot; | &quot;n&quot; |  |
|  &quot;nzzzv&quot; |  &quot;n&quot; | &quot;n&quot; |  |
|  &quot;Nzzzv&quot; |  &quot;N&quot; | &quot;n&quot; |  |
|  function( |  &quot;&lt;leader&gt;vwm&quot; | &quot;n&quot; |  |
|  function( |  &quot;&lt;leader&gt;svwm&quot; | &quot;n&quot; |  |
|  [[&quot;_dP]] |  &quot;&lt;leader&gt;p&quot; | &quot;x&quot; |  |
|  [[&quot;+y]] |  &quot;&lt;leader&gt;y&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  [[&quot;+Y]] |  &quot;&lt;leader&gt;Y&quot; | &quot;n&quot; |  |
|  [[&quot;_d]] |  &quot;&lt;leader&gt;d&quot; | {&quot;n&quot; &quot;v&quot;} |  |
|  &quot;&lt;Esc&gt;&quot; |  &quot;&lt;C-c&gt;&quot; | &quot;i&quot; |  |
|  &quot;&lt;nop&gt;&quot; |  &quot;Q&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;silent !tmux neww tmux-sessionizer&lt;CR&gt;&quot; |  &quot;&lt;C-f&gt;&quot; | &quot;n&quot; |  |
|  vim.lsp.buf.format |  &quot;&lt;leader&gt;f&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cnext&lt;CR&gt;zz&quot; |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;cprev&lt;CR&gt;zz&quot; |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lnext&lt;CR&gt;zz&quot; |  &quot;&lt;leader&gt;k&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;lprev&lt;CR&gt;zz&quot; |  &quot;&lt;leader&gt;j&quot; | &quot;n&quot; |  |
|  [[:%s/\&lt;&lt;C-r&gt;&lt;C-w&gt;\&gt;/&lt;C-r&gt;&lt;C-w&gt;/gI&lt;Left&gt;&lt;Left&gt;&lt;Left&gt;]] |  &quot;&lt;leader&gt;s&quot; | &quot;n&quot; |  |
|  &quot;&lt;cmd&gt;!chmod +x %&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;x&quot; | &quot;n&quot; |  { silent = true } |
|  function( |  &quot;&lt;leader&gt;&lt;leader&gt;&quot; | &quot;n&quot; |  |
|  function( |  &quot;gf&quot; | &quot;n&quot; |  |
|  function( |  &quot;gd&quot; | &quot;n&quot; |  |
| require(&quot;bookmarks&quot;).bookmark_toggle() | &quot;&lt;leader&gt;bm&quot; | &quot;n&quot; |  {--[[ add or remove bookmark at current line]]} |
| require(&quot;bookmarks&quot;).bookmark_toggle() | &quot;&lt;leader&gt;bi&quot; | &quot;n&quot; |  {--[[ add or remove bookmark at current line]]} |
| require(&quot;bookmarks&quot;).bookmark_ann() | &quot;&lt;leader&gt;bme&quot; | &quot;n&quot; |  {--[[add or edit mark annotation at current line]]} |
| require(&quot;bookmarks&quot;).bookmark_ann() | &quot;&lt;leader&gt;be&quot; | &quot;n&quot; |  {--[[add or edit mark annotation at current line]]} |
| require(&quot;bookmarks&quot;).bookmark_clean() | &quot;&lt;leader&gt;bc&quot; | &quot;n&quot; |  {--[[clean all marks in local buffer]]} |
| require(&quot;bookmarks&quot;).bookmark_next() | &quot;&lt;leader&gt;bn&quot; | &quot;n&quot; |  {--[[jump to next mark in local buffer]]} |
| require(&quot;bookmarks&quot;).bookmark_prev() | &quot;&lt;leader&gt;bp&quot; | &quot;n&quot; |  {--[[jump to previous mark in local buffer]]} |
| require(&quot;bookmarks&quot;).bookmark_list() | &quot;&lt;leader&gt;bl&quot; | &quot;n&quot; |  {--[[show marked file list in quickfix window]]} |
|  &quot;&lt;&lt;hhhh&quot; |  &quot;&lt;S-Tab&gt;&quot; | &quot;n&quot; |  |
|  &quot;&gt;&gt;llll&quot; |  &quot;&lt;leader&gt;&lt;Tab&gt;&quot; | &quot;n&quot; |  |
|  &quot;&lt;gv&quot; |  &quot;&lt;S-Tab&gt;&quot; | &quot;v&quot; |  |
|  &quot;&gt;gv&quot; |  &quot;&lt;Tab&gt;&quot; | &quot;v&quot; |  |
|  &quot;:m+&lt;CR&gt;==&quot; |  &quot;&lt;M-j&gt;&quot; | &quot;n&quot; |  |
|  &quot;:m-2&lt;CR&gt;==&quot; |  &quot;&lt;M-k&gt;&quot; | &quot;n&quot; |  |
|  vim.cmd.Git |  &quot;&lt;leader&gt;gs&quot; | &quot;n&quot; |  {--[[Git commit]]} |
|  &quot;&lt;cmd&gt;:Gdiff&lt;CR&gt;&quot; | &quot;&lt;leader&gt;gd&quot; | &quot;n&quot; |  {--[[Git difference]]} |
|  &quot;&lt;cmd&gt;diffget //2&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;gh&quot; | &quot;n&quot; |  {--[[Use left]]} |
|  &quot;&lt;cmd&gt;diffget //2&lt;CR&gt;&quot; |  &quot;gh&quot; | &quot;n&quot; |  {--[[Use left]]} |
|  &quot;&lt;cmd&gt;diffget //3&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;gl&quot; | &quot;n&quot; |  {--[[Use righ]]} |
|  &quot;&lt;cmd&gt;diffget //3&lt;CR&gt;&quot; |  &quot;gl&quot; | &quot;n&quot; |  {--[[Use righ]]} |
|  &quot;&lt;cmd&gt;:Git commit&lt;CR&gt;&quot; | &quot;&lt;leader&gt;gc&quot; | &quot;n&quot; |  {--[[Git commit]]} |
|  &quot;&lt;cmd&gt;:Git push -u origin&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;gp&quot; | &quot;n&quot; |  {--[[Git commit]]} |
|  &quot;adds file to stage or unstage list&quot; |  &quot;a&quot; | &quot;sb&quot; |  {--[[Adds file to stage or unstage list]]} |
|  &quot;resets changes to file&quot; |  &quot;X&quot; | &quot;sb&quot; |  {--[[Resets changes to file]]} |
|  &quot;&lt;cmd&gt;:NvimTreeToggle&lt;CR&gt;&quot; |  &quot;&lt;leader&gt;sb&quot; | &quot;n&quot; |  {--[[Toggle SideBar]]} |
|  &quot;new file/dir&quot; |  &quot;a&quot; | &quot;sb&quot; |  {--[[Crete new file or dir (ends in /)]]} |
|  &quot;rename&quot; |  &quot;r&quot; | &quot;sb&quot; |  {--[[Rename]]} |
|  &quot;rename without initial name&quot; |  &quot;&lt;C-r&gt;&quot; | &quot;sb&quot; |  {--[[Rename without initial name]]} |
|  &quot;delete&quot; |  &quot;d&quot; | &quot;sb&quot; |  {--[[Delete]]} |
|  &quot;cut&quot; |  &quot;x&quot; | &quot;sb&quot; |  {--[[Cut]]} |
|  &quot;paste&quot; |  &quot;p&quot; | &quot;sb&quot; |  {--[[Paste]]} |
|  &quot;copy&quot; |  &quot;c&quot; | &quot;sb&quot; |  {--[[Copy]]} |
|  &quot;copy filename&quot; |  &quot;y&quot; | &quot;sb&quot; |  {--[[Copy filename]]} |
|  &quot;copy filename with relative path&quot; |  &quot;Y&quot; | &quot;sb&quot; |  {--[[Copy filename with relative path]]} |
|  &quot;copy filename with absolute path&quot; |  &quot;g+y&quot; | &quot;sb&quot; |  {--[[Copy filename with absolute path]]} |
|  &quot;open file but keepcursor on tree&quot; |  &quot;Tab&quot; | &quot;sb&quot; |  {--[[Open file but keepcursor on tree]]} |
|  &quot;open file w/ vertical split&quot; |  &quot;&lt;C-v&gt;&quot; | &quot;sb&quot; |  {--[[Open file with vertical split]]} |
|  &quot;open file w/ horizontal split&quot; |  &quot;&lt;C-h&gt;&quot; | &quot;sb&quot; |  {--[[Open file with horizontal split]]} |
|  builtin.find_files |  &#x27;&lt;leader&gt;pf&#x27; | &#x27;n&#x27; |  {} |
|  builtin.live_grep |  &#x27;&lt;leader&gt;pg&#x27; | &#x27;n&#x27; |  {} |
|  function( |  &#x27;&lt;leader&gt;ps&#x27; | &#x27;n&#x27; |  |
|  vim.cmd.Git |  &quot;&lt;leader&gt;gs&quot; | &quot;n&quot; |  |
|  mark.add_file |  &quot;&lt;leader&gt;a&quot; | &quot;n&quot; |  |
|  ui.toggle_quick_menu |  &quot;&lt;C-e&gt;&quot; | &quot;n&quot; |  |
|  ui.nav_file(1) |  &quot;&lt;C-h&gt;&quot; | &quot;n&quot; |  |
|  ui.nav_file(2) |  &quot;&lt;C-j&gt;&quot; | &quot;n&quot; |  |
|  ui.nav_file(3) |  &quot;&lt;C-k&gt;&quot; | &quot;n&quot; |  |
|  ui.nav_file(4) |  &quot;&lt;C-l&gt;&quot; | &quot;n&quot; |  |
|  vim.cmd.UndotreeToggle |  &quot;&lt;leader&gt;u&quot; |  &quot;n&quot; |  |
|  |  |  |  |