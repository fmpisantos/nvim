# Agent Guidelines for Neovim Configuration

## Build/Lint/Test Commands
- **Lint**: Lua LSP diagnostics via `.luarc.json` (no dedicated linter)
- **Test**: Manual - run Neovim and verify plugin configurations
- **Single test**: Load specific modules manually for testing

## Code Style Guidelines
### Imports & Structure
- Use `require()` for imports at file top or in setup functions
- Plugin files return tables with `src` and `setup` fields
- Example: `local builtin = require('telescope.builtin')`

### Formatting & Naming
- 4-space indentation, consistent spacing, logical line breaks
- snake_case for functions/variables (e.g., `buffer_dir`, `toggle_fold_under_cursor`)
- UPPER_CASE for constants (minimal usage)

### Types & Error Handling
- Dynamic typing - use descriptive names for type indication
- Use `pcall()` for optional operations, check nil values, provide fallbacks

### Best Practices
- `vim.keymap.set()` with `desc` field for key mappings
- `vim.api.nvim_create_autocmd()` for autocommands
- `vim.opt` for options, prefer `vim.api` over `vim.cmd()`
- Group related functionality in separate files