-- Phantom color scheme for Neovim
-- Inspired by the Monkeytype Phantom theme
-- A dark theme with light blue accents and glowing effects

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "phantom"

-- Color palette
local colors = {
  -- Background colors
  bg = "#0d1117",           -- Deep dark background
  bg_alt = "#161b22",       -- Slightly lighter background
  bg_highlight = "#21262d", -- Highlighted background
  bg_popup = "#1c2128",     -- Popup background
  bg_sidebar = "#0d1117",   -- Sidebar background
  
  -- Foreground colors
  fg = "#c9d1d9",           -- Main foreground
  fg_alt = "#8b949e",       -- Dimmed foreground
  fg_gutter = "#484f58",    -- Gutter foreground
  
  -- Blue accent colors (phantom theme)
  blue = "#58a6ff",         -- Bright blue (main accent)
  blue_light = "#79c0ff",   -- Light blue (glowing effect)
  blue_dark = "#1f6feb",    -- Dark blue
  blue_dim = "#388bfd",     -- Dimmed blue
  
  -- Additional colors
  cyan = "#39d0d8",         -- Cyan
  green = "#56d364",        -- Green
  yellow = "#e3b341",       -- Yellow
  orange = "#ffa657",       -- Orange
  red = "#f85149",          -- Red
  purple = "#a5a2ff",       -- Purple
  pink = "#ffa5d3",         -- Pink
  
  -- UI colors
  border = "#30363d",       -- Border color
  selection = "#264f78",    -- Selection background
  search = "#3d3d1a",       -- Search highlight (darker yellow)
  match = "#ffd33d",        -- Match highlight
  
  -- Special
  none = "NONE",
}

-- Helper function to set highlights
local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor highlights
hl("Normal", { fg = colors.fg, bg = colors.bg })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg_popup })
hl("NormalNC", { fg = colors.fg, bg = colors.bg })
hl("LineNr", { fg = colors.fg_gutter })
hl("CursorLineNr", { fg = colors.blue_light, bold = true })
hl("CursorLine", { bg = colors.bg_highlight })
hl("CursorColumn", { bg = colors.bg_highlight })
hl("ColorColumn", { bg = colors.bg_alt })
hl("Cursor", { fg = colors.bg, bg = colors.blue })
hl("Visual", { bg = colors.selection })
hl("VisualNOS", { bg = colors.selection })
hl("Search", { bg = colors.search })
hl("IncSearch", { fg = colors.bg, bg = colors.match })
hl("MatchParen", { fg = colors.blue_light, bold = true, underline = true })

-- Window elements
hl("WinSeparator", { fg = colors.border })
hl("VertSplit", { fg = colors.border })
hl("StatusLine", { fg = colors.fg, bg = colors.bg_alt })
hl("StatusLineNC", { fg = colors.fg_alt, bg = colors.bg_alt })
hl("TabLine", { fg = colors.fg_alt, bg = colors.bg_alt })
hl("TabLineFill", { bg = colors.bg_alt })
hl("TabLineSel", { fg = colors.blue_light, bg = colors.bg })

-- Syntax highlighting
hl("Comment", { fg = colors.fg_alt, italic = true })
hl("Constant", { fg = colors.orange })
hl("String", { fg = colors.green })
hl("Character", { fg = colors.green })
hl("Number", { fg = colors.orange })
hl("Boolean", { fg = colors.blue })
hl("Float", { fg = colors.orange })

hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.blue_light, bold = true })

hl("Statement", { fg = colors.blue, bold = true })
hl("Conditional", { fg = colors.blue })
hl("Repeat", { fg = colors.blue })
hl("Label", { fg = colors.blue })
hl("Operator", { fg = colors.cyan })
hl("Keyword", { fg = colors.blue, bold = true })
hl("Exception", { fg = colors.red })

hl("PreProc", { fg = colors.purple })
hl("Include", { fg = colors.purple })
hl("Define", { fg = colors.purple })
hl("Macro", { fg = colors.purple })
hl("PreCondit", { fg = colors.purple })

hl("Type", { fg = colors.yellow })
hl("StorageClass", { fg = colors.blue })
hl("Structure", { fg = colors.yellow })
hl("Typedef", { fg = colors.yellow })

hl("Special", { fg = colors.cyan })
hl("SpecialChar", { fg = colors.cyan })
hl("Tag", { fg = colors.blue })
hl("Delimiter", { fg = colors.fg_alt })
hl("SpecialComment", { fg = colors.cyan, italic = true })
hl("Debug", { fg = colors.red })

-- Error and warning
hl("Error", { fg = colors.red, bold = true })
hl("ErrorMsg", { fg = colors.red, bold = true })
hl("WarningMsg", { fg = colors.yellow, bold = true })
hl("Todo", { fg = colors.yellow, bg = colors.bg_alt, bold = true })

-- Diff
hl("DiffAdd", { fg = colors.green, bg = colors.bg_alt })
hl("DiffChange", { fg = colors.yellow, bg = colors.bg_alt })
hl("DiffDelete", { fg = colors.red, bg = colors.bg_alt })
hl("DiffText", { fg = colors.blue, bg = colors.bg_alt, bold = true })

-- Popup menu
hl("Pmenu", { fg = colors.fg, bg = colors.bg_popup })
hl("PmenuSel", { fg = colors.blue_light, bg = colors.bg_highlight, bold = true })
hl("PmenuSbar", { bg = colors.bg_alt })
hl("PmenuThumb", { bg = colors.blue })

-- Folding
hl("Folded", { fg = colors.fg_alt, bg = colors.bg_alt, italic = true })
hl("FoldColumn", { fg = colors.fg_gutter, bg = colors.bg })

-- Spell checking
hl("SpellBad", { undercurl = true, sp = colors.red })
hl("SpellCap", { undercurl = true, sp = colors.blue })
hl("SpellLocal", { undercurl = true, sp = colors.cyan })
hl("SpellRare", { undercurl = true, sp = colors.purple })

-- LSP highlights
hl("DiagnosticError", { fg = colors.red })
hl("DiagnosticWarn", { fg = colors.yellow })
hl("DiagnosticInfo", { fg = colors.blue })
hl("DiagnosticHint", { fg = colors.cyan })
hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.blue })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.cyan })

-- LSP semantic highlighting
hl("@variable", { fg = colors.fg })
hl("@variable.builtin", { fg = colors.red })
hl("@variable.parameter", { fg = colors.fg })
hl("@variable.member", { fg = colors.fg })

hl("@constant", { fg = colors.orange })
hl("@constant.builtin", { fg = colors.orange })
hl("@constant.macro", { fg = colors.orange })

hl("@module", { fg = colors.purple })
hl("@label", { fg = colors.blue })

hl("@string", { fg = colors.green })
hl("@string.regexp", { fg = colors.cyan })
hl("@string.escape", { fg = colors.cyan })

hl("@character", { fg = colors.green })
hl("@character.special", { fg = colors.cyan })

hl("@number", { fg = colors.orange })
hl("@number.float", { fg = colors.orange })

hl("@boolean", { fg = colors.blue })

hl("@annotation", { fg = colors.purple })
hl("@attribute", { fg = colors.purple })
hl("@error", { fg = colors.red })

hl("@keyword", { fg = colors.blue, bold = true })
hl("@keyword.function", { fg = colors.blue })
hl("@keyword.return", { fg = colors.blue })
hl("@keyword.operator", { fg = colors.cyan })

hl("@operator", { fg = colors.cyan })

hl("@punctuation.bracket", { fg = colors.fg_alt })
hl("@punctuation.delimiter", { fg = colors.fg_alt })
hl("@punctuation.special", { fg = colors.cyan })

hl("@comment", { fg = colors.fg_alt, italic = true })
hl("@comment.todo", { fg = colors.yellow, bg = colors.bg_alt, bold = true })
hl("@comment.note", { fg = colors.blue, bg = colors.bg_alt, bold = true })
hl("@comment.warning", { fg = colors.yellow, bg = colors.bg_alt, bold = true })
hl("@comment.error", { fg = colors.red, bg = colors.bg_alt, bold = true })

hl("@type", { fg = colors.yellow })
hl("@type.builtin", { fg = colors.yellow })
hl("@type.definition", { fg = colors.yellow })

hl("@function", { fg = colors.blue_light, bold = true })
hl("@function.builtin", { fg = colors.blue_light })
hl("@function.macro", { fg = colors.purple })
hl("@function.method", { fg = colors.blue_light })

hl("@constructor", { fg = colors.yellow })

hl("@tag", { fg = colors.blue })
hl("@tag.attribute", { fg = colors.yellow })
hl("@tag.delimiter", { fg = colors.fg_alt })

-- Treesitter context
hl("TreesitterContext", { bg = colors.bg_alt })
hl("TreesitterContextLineNumber", { fg = colors.blue, bg = colors.bg_alt })

-- Git signs
hl("GitSignsAdd", { fg = colors.green })
hl("GitSignsChange", { fg = colors.yellow })
hl("GitSignsDelete", { fg = colors.red })

-- Telescope
hl("TelescopeNormal", { fg = colors.fg, bg = colors.bg_popup })
hl("TelescopeBorder", { fg = colors.border, bg = colors.bg_popup })
hl("TelescopePromptNormal", { fg = colors.fg, bg = colors.bg_highlight })
hl("TelescopePromptBorder", { fg = colors.blue, bg = colors.bg_highlight })
hl("TelescopePromptTitle", { fg = colors.blue_light, bold = true })
hl("TelescopePreviewTitle", { fg = colors.green, bold = true })
hl("TelescopeResultsTitle", { fg = colors.fg_alt, bold = true })
hl("TelescopeSelection", { fg = colors.blue_light, bg = colors.bg_highlight, bold = true })
hl("TelescopeMatching", { fg = colors.match, bold = true })

-- Which-key
hl("WhichKey", { fg = colors.blue_light, bold = true })
hl("WhichKeyGroup", { fg = colors.purple })
hl("WhichKeyDesc", { fg = colors.fg })
hl("WhichKeySeperator", { fg = colors.fg_alt })
hl("WhichKeyFloat", { bg = colors.bg_popup })
hl("WhichKeyBorder", { fg = colors.border })

-- NvimTree
hl("NvimTreeNormal", { fg = colors.fg, bg = colors.bg_sidebar })
hl("NvimTreeFolderName", { fg = colors.blue })
hl("NvimTreeFolderIcon", { fg = colors.blue })
hl("NvimTreeOpenedFolderName", { fg = colors.blue_light, bold = true })
hl("NvimTreeSymlink", { fg = colors.cyan })
hl("NvimTreeExecFile", { fg = colors.green })

-- Dashboard/Alpha
hl("AlphaShortcut", { fg = colors.orange })
hl("AlphaHeader", { fg = colors.blue_light })
hl("AlphaHeaderLabel", { fg = colors.blue })
hl("AlphaFooter", { fg = colors.fg_alt, italic = true })
hl("AlphaButtons", { fg = colors.cyan })

-- Indent guides
hl("IndentBlanklineChar", { fg = colors.fg_gutter })
hl("IndentBlanklineContextChar", { fg = colors.blue })

-- Notify
hl("NotifyBackground", { bg = colors.bg_popup })
hl("NotifyERRORBorder", { fg = colors.red })
hl("NotifyWARNBorder", { fg = colors.yellow })
hl("NotifyINFOBorder", { fg = colors.blue })
hl("NotifyDEBUGBorder", { fg = colors.fg_alt })
hl("NotifyTRACEBorder", { fg = colors.purple })

-- Make the theme feel more "glowing" with some special highlights
hl("CursorLineNr", { fg = colors.blue_light, bold = true, bg = colors.bg_highlight })

-- Additional plugin support
-- Cmp (completion)
hl("CmpItemAbbr", { fg = colors.fg })
hl("CmpItemAbbrDeprecated", { fg = colors.fg_alt, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = colors.blue_light, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = colors.blue_light, bold = true })
hl("CmpItemKind", { fg = colors.purple })
hl("CmpItemMenu", { fg = colors.fg_alt })

-- Lualine
hl("lualine_a_normal", { fg = colors.bg, bg = colors.blue, bold = true })
hl("lualine_b_normal", { fg = colors.fg, bg = colors.bg_alt })
hl("lualine_c_normal", { fg = colors.fg_alt, bg = colors.bg })

-- Neo-tree
hl("NeoTreeNormal", { fg = colors.fg, bg = colors.bg_sidebar })
hl("NeoTreeDirectoryName", { fg = colors.blue })
hl("NeoTreeDirectoryIcon", { fg = colors.blue })
hl("NeoTreeFileName", { fg = colors.fg })
hl("NeoTreeFileIcon", { fg = colors.fg_alt })
hl("NeoTreeModified", { fg = colors.orange })
hl("NeoTreeGitAdded", { fg = colors.green })
hl("NeoTreeGitModified", { fg = colors.yellow })
hl("NeoTreeGitDeleted", { fg = colors.red })

-- Bufferline
hl("BufferLineIndicatorSelected", { fg = colors.blue_light })
hl("BufferLineFill", { bg = colors.bg_alt })

-- Noice
hl("NoicePopup", { bg = colors.bg_popup })
hl("NoiceCmdlinePopup", { bg = colors.bg_popup })
hl("NoiceCmdlineIcon", { fg = colors.blue })

-- Leap
hl("LeapMatch", { fg = colors.match, bold = true, underline = true })
hl("LeapLabelPrimary", { fg = colors.blue_light, bold = true })
hl("LeapLabelSecondary", { fg = colors.purple, bold = true })

print("Phantom theme loaded successfully!")
