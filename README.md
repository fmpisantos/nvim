# pack.nvim (nvim-version: > 0.12.0)

A lightweight Neovim plugin manager that simplifies plugin organization and batch installation with interactive prompts.

## Installation

Add pack.nvim to your Neovim configuration:

```lua
vim.pack.add({"https://github.com/fmpisantos/pack.nvim"})
```

## Quick Start

```lua
local pack = require("pack")

-- Add plugins from a directory
pack.require("plugins")

-- Add a specific plugin file
pack.require("plugins.example.init")

-- Install all queued plugins with a single prompt
pack.install()
```

## API Reference

### `pack.require(path)`

Adds plugin sources to the installation queue.

**Parameters:**
- `path` (string): The module path to require
  - Use folder paths to include all files in a directory
  - Use dot notation for file paths (e.g., `"plugins.example.init"`)
  - Dots (`.`) represent directory separators (`/`)

**Examples:**
```lua
-- Add all plugins from the plugins/ directory
pack.require("plugins")

-- Add a specific plugin configuration file
pack.require("plugins.lsp.init")
pack.require("plugins.ui.statusline")
```

### `pack.install()`

Executes the installation process for all queued plugin sources.

**Behavior:**
- Runs `vim.pack.add()` for each queued source
- Calls `.setup()` on each installed plugin
- Groups all queued sources into a single installation prompt
- Clears the queue after installation

**Example:**
```lua
-- Queue multiple plugins
pack.require("plugins.editor")
pack.require("plugins.git")
pack.require("plugins.lsp")

-- Install all queued plugins with one prompt
pack.install()
```

## Usage Patterns

### Basic Plugin Organization

Organize your plugins in separate files and directories:

```
lua/
├── plugins/
│   ├── init.lua          -- Core plugins
│   ├── editor.lua        -- Editor enhancements
│   ├── lsp/
│   │   ├── init.lua      -- LSP configuration
│   │   └── servers.lua   -- Server configs
│   └── ui/
│       ├── colorscheme.lua
│       └── statusline.lua
```

```lua
local pack = require("pack")

-- Load core plugins
pack.require("plugins")

-- Load LSP configuration
pack.require("plugins.lsp")

-- Install everything in one go
pack.install()
```

### Grouped Installation

You can create separate installation groups for different types of plugins:

```lua
local pack = require("pack")

-- Group 1: Essential plugins
pack.require("plugins.core")
pack.require("plugins.editor")
pack.install() -- First installation prompt

-- Group 2: Optional enhancements
pack.require("plugins.ui")
pack.require("plugins.extras")
pack.install() -- Second installation prompt
```

### Conditional Plugin Loading

```lua
local pack = require("pack")

-- Always load core plugins
pack.require("plugins.core")

-- Conditionally load development plugins
if vim.fn.isdirectory(".git") == 1 then
  pack.require("plugins.git")
  pack.require("plugins.dev")
end

pack.install()
```

## File Structure Examples

### Plugin Configuration Files

Each plugin file should return a configuration table. The `src` field follows the same specification as `vim.pack.add()`, supporting all the same options and formats.

#### Simple Plugin Configuration
```lua
-- plugins/editor.lua
return {
    src = "nvim-treesitter/nvim-treesitter",
    deps = {
        "windwp/nvim-autopairs",
        {src = "numToStr/Comment.nvim"} 
    }
}
```

#### Plugin with Setup Function
```lua
-- plugins/lsp/init.lua
return {
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  setup = function()
    -- LSP setup code here
  end
}
```

#### Advanced Plugin Configuration
The `src` field supports all `vim.pack.add()` specifications, including lazy loading, build commands, and event triggers:

```lua
-- plugins/markdown.lua
return {
    src = {
        {
            src = "iamcco/markdown-preview.nvim",
            event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = "cd app && yarn install && git restore ."
        },
    }
}
```

#### Supported `src` Formats

Since pack.nvim uses `vim.pack.add()` internally, your `src` field can use any format supported by `vim.pack.add()`:

- **String format**: `src = "owner/repo"`
- **Table format**: `src = { src = "owner/repo", event = "VeryLazy" }`
- **Array of plugins**: `src = { "plugin1", "plugin2", { src = "plugin3" } }`
- **Full specification**: Including `event`, `cmd`, `ft`, `build`, `dependencies`, etc.

All standard `vim.pack.add()` options are supported:
- `event` - Lazy load on events
- `cmd` - Lazy load on commands  
- `ft` - Lazy load on filetypes
- `build` - Post-install build commands
- `dependencies` - Plugin dependencies
- `config` - Configuration function

## Benefits

- **Organized Configuration**: Keep related plugins grouped in logical files and directories
- **Batch Installation**: Install multiple plugins with a single confirmation prompt
- **Flexible Loading**: Load plugins conditionally or in separate groups
- **Simple API**: Just two main functions to learn and use
- **Path Flexibility**: Use directory paths or specific file paths as needed

## Tips

1. **Group Related Plugins**: Keep similar functionality together (LSP, UI, editor tools)
2. **Use Descriptive Paths**: Make your plugin organization self-documenting
3. **Separate Optional Plugins**: Use multiple `install()` calls to separate essential from optional plugins
4. **Leverage Conditionals**: Only load plugins when needed based on project type or environment

## Troubleshooting

- Ensure all required paths exist and contain valid Lua modules
- Check that plugin files return proper configuration tables
- Verify paths use dot notation correctly (dots instead of slashes)
- Make sure `pack.install()` is called after all `pack.require()` calls for each group

---

# This Neovim configuration

Reference for everything this config adds on top of stock Neovim: every user
command, every keymap that differs from the default, and the option/behaviour
changes worth knowing about.

Requires **Neovim ≥ 0.12** (uses `vim.pack`, `vim.lsp.config`, and the
nvim-treesitter `main` branch).

## Contents

- [Layout & load order](#layout--load-order)
- [External tools](#external-tools)
- [Commands](#commands)
  - [Always available](#commands--always-available)
  - [Files & search](#commands--files--search)
  - [AI assistants](#commands--ai-assistants)
  - [Debugging (DAP)](#commands--debugging-dap)
  - [LSP buffers only](#commands--lsp-buffers-only)
  - [Java buffers only](#commands--java-buffers-only)
  - [Context-specific](#commands--context-specific)
- [Keymaps](#keymaps)
  - [Overridden built-ins](#keymaps--overridden-built-ins)
  - [Editing & movement](#keymaps--editing--movement)
  - [Clipboard](#keymaps--clipboard)
  - [Windows & folds](#keymaps--windows--folds)
  - [Files & navigation](#keymaps--files--navigation)
  - [Search (Telescope)](#keymaps--search-telescope)
  - [Harpoon](#keymaps--harpoon)
  - [LSP](#keymaps--lsp)
  - [Diagnostics & quickfix](#keymaps--diagnostics--quickfix)
  - [Git](#keymaps--git)
  - [Terminals](#keymaps--terminals)
  - [Diff view](#keymaps--diff-view)
  - [Debugging (DAP)](#keymaps--debugging-dap)
  - [AI assistants](#keymaps--ai-assistants)
  - [Completion (nvim-cmp)](#keymaps--completion-nvim-cmp)
  - [Oil](#keymaps--oil)
  - [Prompt buffers](#keymaps--prompt-buffers)
- [Options that differ from defaults](#options-that-differ-from-defaults)
- [Automatic behaviours](#automatic-behaviours)
- [Known collisions & rough edges](#known-collisions--rough-edges)

## Layout & load order

```
init.lua                 -- leader, :FormatOnSave*, bootstraps pack.nvim
lua/set.lua              -- options, shell, <C-f> sessionizer
lua/netrw_config.lua     -- netrw options, :Fd :Find :Rg
lua/remap.lua            -- core keymaps, :Open :Location :Translate ...
lua/plugins/*.lua        -- one file per plugin, auto-loaded by pack.require("plugins")
lua/plugins/extensions.lua  -- global helper functions (not a plugin spec)
lua/plugins/lsp-keymaps.lua -- shared LSP on_attach (not a plugin spec)
lua/plugins/java/        -- jdtls + java DAP config (required by lsp.lua)
lua/plugins/jsts/        -- JS/TS DAP config (required by lsp.lua)
lua/plugins/myPlugins/   -- floating terminal + floating diff view
lua/plugins/disabled/    -- NOT loaded (see below)
lua/claude_code/         -- local Claude Code CLI integration
ftplugin/*.lua           -- per-filetype buffer-local setup
snippets/                -- LuaSnip snippets
```

`pack.require("plugins")` only reads **top-level `.lua` files** in
`lua/plugins/`. Subdirectories are never auto-loaded, which is why
`lua/plugins/disabled/` is inert and `java/`, `jsts/`, `myPlugins/` are pulled
in explicitly by the modules that need them.

If `FROM_WEZTERM=1` is set in the environment, `init.lua` returns right after
loading `set`, `netrw_config` and `remap` — no plugins at all. Useful for
throwaway edits.

## External tools

Not all of these are required; each is only needed by the feature next to it.

| Tool | Needed for |
| --- | --- |
| `git` | `:Find`, `:FormatAll`, fugitive, lazygit |
| `fd` | `:Fd`, `<leader>hh` source/header lookup |
| `rg` (ripgrep) | `:Rg` (command is not created without it), Telescope live grep |
| `lazygit` | `<leader>lg` |
| `claude` | `:ClaudeCode` / `<leader>ca` |
| `opencode` | `:OpenCode` / `<leader>oc` |
| `aws` CLI + `static-websites` profile | `:S3Ls`, `:S3Deploy` |
| `mvn`, `gradle` / `./gradlew` | Java build, test and debug flows |
| SDKMAN java installs | `compile_gradle` picks a JDK from `~/.sdkman/candidates/java/` |
| `prettier` | `:ConformFormat` |
| `tmux` + `~/.local/bin/tmux-sessionizer` | `<C-f>` |
| `DEEPL_API_KEY` env var | `:Translate` |
| `npm` | markdown-preview build step |

---

## Commands

### Commands — always available

| Command | Does |
| --- | --- |
| `:FormatOnSave on\|off` | Enable/disable auto-format on save (`vim.g.format_on_save`). Off at startup. Currently only wired up for Java buffers. |
| `:FormatOnSaveToggle` | Flip the same flag. |
| `:Open` | Open the current **file** with the OS default application (`open` / `explorer` / `xdg-open`). |
| `:OpenDirectory` | Open the current file's **directory** in the OS file manager. |
| `:Location` | Echo and copy `relative/path:line` to the system clipboard. |
| `:FullLocation` | Same, with the absolute path. |
| `:Translate` | Translate the visual selection to English via DeepL and show it in a floating window. Needs `DEEPL_API_KEY`. Accepts a range. |
| `:ClearMarks` | `delm A-Z 0-9 a-z` — wipe all marks. |
| `:DelAllMarks` | Identical alias of `:ClearMarks`. |
| `:DiffView` | Open two side-by-side floating scratch buffers in diff mode. Fill them with `<leader>d1` / `<leader>d2`. |
| `:ConformFormat` | Format the buffer with conform.nvim (prettier for html/css/scss/js/ts/jsx/tsx/json/yaml/markdown). |

### Commands — files & search

| Command | Does |
| --- | --- |
| `:Fd {pattern}` | Find files with `fd` (max 50 results, 5s result cache) and open. One match opens directly; several show a `vim.ui.select` picker. Tab-completes from the same `fd` results. |
| `:Find {pattern}` | Search `git ls-files` (tracked + untracked, respecting gitignore). Case-insensitive substring, or glob when the pattern contains `*` / `?`. |
| `:Rg {pattern} [rg-flags...]` | Ripgrep into the quickfix list and `:copen`. Uses `--vimgrep --smart-case`. **Only defined if `rg` is on `PATH`.** |
| `:Telescope ...` | Full Telescope command surface (see the keymaps section for the bound pickers). |

### Commands — AI assistants

Both integrations share the same shape: a floating prompt window, a streaming
response split, and model / mode / session pickers.

**Claude Code** (`lua/claude_code/`, drives the `claude` CLI). Every command has
a long `ClaudeCode*` form and a short `CA*` alias.

| Command | Does |
| --- | --- |
| `:ClaudeCode` / `:CA` | Open the prompt window. |
| `:ClaudeCodeWSelection` / `:CAWSelection` | Open the prompt pre-filled with the visual selection in a fenced code block. |
| `:ClaudeCodeMode [mode]` / `:CAMode` | Set the execution mode, or cycle it when called with no argument. Completes `agent`, `plan`, `ask`, `quick`. |
| `:ClaudeCodeModel` / `:CAModel` | Pick the model (aliases `opus`/`sonnet`/`haiku`/`fable`, or a pinned model id). |
| `:ClaudeCodeSessions` / `:CASessions` | Telescope picker over past sessions for this cwd, with the prompt history as preview. Selecting one resumes it. |
| `:ClaudeCodeNew` / `:CANew` | Drop the current session reference so the next prompt starts fresh. |
| `:ClaudeCodeCLI` / `:CACLI` | Toggle the response split. |
| `:ClaudeCodeStop` / `:CAStop` | Kill every in-flight request and clear the queue. |

Modes map onto real CLI flags, so the restrictions are enforced by the process,
not by prompting:

| Mode | Behaviour |
| --- | --- |
| `agent` | Full tool access (`--permission-mode bypassPermissions`). |
| `plan` | Read-only planning (`--permission-mode plan`). |
| `ask` | Read-only Q&A — only `Read,Grep,Glob,WebFetch,WebSearch` are available. |
| `quick` | **No tools at all.** The contents of every `@file` you reference are inlined into the prompt instead. |

Inside the prompt window you can also write `#agent` / `#plan` / `#ask` /
`#quick` to override the mode for one message, and `#session` on its own to open
the session picker.

**OpenCode** (`opencode.nvim`, drives the `opencode` CLI). Long `OpenCode*` and
short `OC*` forms:

`:OpenCode`/`:OC`, `:OpenCodeWSelection`, `:OpenCodeMode`/`:OCMode`,
`:OpenCodeModel`/`:OCModel`, `:OpenCodeAgent`/`:OCAgent`,
`:OpenCodeSessions`/`:OCSessions`, `:OpenCodeReview`/`:OCReview`,
`:OpenCodeInit`/`:OCInit`, `:OpenCodeCLI`/`:OCCLI`,
`:OpenCodeAttachWindow`/`:OCAttachWindow`, `:OpenCodeStop`/`:OCStop`,
`:OpenCodeServerStatus`/`:OCServerStatus`,
`:OpenCodeServerStart`/`:OCServerStart`, `:OpenCodeServerStop`/`:OCServerStop`,
`:OpenCodeServerRestart`, `:OCConfig`.

### Commands — debugging (DAP)

| Command | Does |
| --- | --- |
| `:DapRepl` | Open the DAP REPL. |
| `:DapClearBreakpoints` | Remove every breakpoint. |
| `:DapBreakpointCondition` | Prompt for an expression and set a conditional breakpoint on the current line. |
| `:DapConsole` | Open the dap-ui console in a horizontal split. |
| `:DapStacks` | Open the stack frames in a vertical split. |
| `:DapWatch` | Open the watches element in a split. |
| `:DapBreakpointsList` | List breakpoints in a vertical split. ⚠️ currently broken — see [known issues](#known-collisions--rough-edges). |
| `:DapRunToCursor` | Continue until the cursor line. |
| `:DapFocus` | Jump the cursor to the current stack frame. |
| `:Mvnnt` / `:DapCleanInstall` | Clear the jdtls workspace data dir, then rebuild (Maven `clean install -DskipTests`, or `gradlew build -x test`). |
| `:DockerUp` | `./gradlew composeUp`. |
| `:DockerDown` | `./gradlew composeDown`. |

The build step auto-detects Maven vs Gradle from `pom.xml` /
`build.gradle[.kts]`, reads the source/target Java version out of the build file
and, for Gradle, points `-Dorg.gradle.java.home` at a matching SDKMAN JDK.

### Commands — LSP buffers only

Buffer-local; created by `on_attach`, so they exist **only in buffers with an
attached LSP client**.

| Command | Does |
| --- | --- |
| `:Format` | Format the buffer, then organize imports (via jdtls in Java, otherwise the `source.organizeImports` code action). Writes the file only if something changed. |
| `:FormatAll [git-param [hash]]` | Format many files asynchronously, showing `[n/total]` progress and a summary. With no argument: every tracked + untracked non-ignored file. |
| `:FormatAllType <filetype> [git-param [hash]]` | Same, restricted to one filetype (matched via `vim.filetype.match`, so it does not depend on the file being open). |
| `:Rename` | Prompt for a new filename, rename the file on disk, reopen it and wipe the old buffer. |

`git-param` selects the file set:

| Value | Files |
| --- | --- |
| *(omitted)* | Everything `git ls-files --cached --others --exclude-standard` returns. |
| `staged` | Staged changes. |
| `unstaged` | Modified-but-unstaged plus untracked non-ignored files. |
| `commit` | Staged + unstaged + untracked. |
| `commit <hash>` | Files touched by that one commit. |
| `local` | Staged + unstaged + untracked + everything committed on this branch but not yet pushed (`@{u}..HEAD`). |

Both commands complete their arguments. Files are loaded into hidden buffers
(no window churn), each buffer is marked `format_in_progress` so save hooks and
codelens refreshes skip it, and Java files wait for jdtls to actually attach
(60 s for the first file, 5 s after that) rather than formatting against a
server that is not ready. The summary reports `wrote N`, plus `no-lsp`,
`no-formatter`, `errors` and `skipped-timeout` counts when non-zero.

### Commands — Java buffers only

Buffer-local, from `ftplugin/java.lua`.

| Command | Does |
| --- | --- |
| `:make` | Runs `<gradle-root>/gradlew build -x test`. `errorformat` parses javac errors and warnings into the quickfix list; Gradle's own `\|\|` noise is filtered out. The gradle root comes from the attached jdtls client, so this only works once jdtls is up. |
| `:MakeClean` | Same but `gradlew clean build`, and runs `:make` immediately. |

### Commands — context-specific

| Command | Available when | Does |
| --- | --- | --- |
| `:S3Ls [bucket] [profile]` | Always | Browse the S3 bucket (defaults to `teamsantos-static-websites` / profile `static-websites`). |
| `:S3Deploy` | Always | Deploy via s3.nvim. |
| `:DeployLambda` | cwd/buffers are in the `fmpisantos/static-websites` repo | Detect the lambda name from the path (`.../lambda/<name>/...`) and run `~/Projects/static-websites/scripts/deploy-lambda.sh` asynchronously. Works from `oil://` buffers too. |
| `:LazyGit`, `:LazyGitConfig`, `:LazyGitCurrentFile`, `:LazyGitFilter`, `:LazyGitFilterCurrentFile` | Always | lazygit.nvim. |
| `:UndotreeToggle`, `:UndotreeShow`, `:UndotreeHide`, `:UndotreeFocus` | Always | undotree. |
| `:MarkdownPreview`, `:MarkdownPreviewStop`, `:MarkdownPreviewToggle` | markdown files | Live browser preview. |
| `:DBUI`, `:DBUIToggle`, `:DBUIAddConnection`, `:DBUIFindBuffer` | Always | vim-dadbod-ui. SQL buffers additionally get dadbod completion in cmp. |
| `:Git`, `:Gdiff`, `:Gread`, `:Gwrite`, … | Always | vim-fugitive. |
| `:Mason`, `:MasonUpdate`, `:MasonInstall`, `:MasonLog` | Always | Mason. `:MasonUpdate` also runs automatically at startup. |

---

## Keymaps

Leader and local-leader are both **Space**.

Modes: `n` normal, `i` insert, `v` visual, `x` visual-block, `t` terminal.

### Keymaps — overridden built-ins

These replace or shadow stock Neovim behaviour, so they are the ones most worth
knowing about.

| Key | Mode | Now does | Stock behaviour |
| --- | --- | --- | --- |
| `-` | n | Open **oil.nvim** in the parent directory | Move to first non-blank of line above |
| `n` / `N` | n | Next/previous search hit, then `zzzv` (recentre, keep folds) | Next/previous hit |
| `Q` | n | Nothing (`<nop>`) | Ex mode |
| `K` | n | LSP hover *(LSP buffers)* | `keywordprg` lookup |
| `H` | n | LSP signature help *(LSP buffers)* | Jump to top of window |
| `gd` | n | Telescope LSP definitions | Local declaration jump |
| `gh` / `gl` | n | Fugitive `diffget //2` / `//3` (take left/right hunk) | `gh` select-mode; `gl` unused |
| `<Esc>` | n | `:nohlsearch` | Nothing |
| `<Tab>` | v | Indent selection and keep it selected (`>gv`) | Nothing useful |
| `<S-Tab>` | n | Dedent line and step 4 columns left | Nothing |
| `<S-Tab>` | v | Dedent selection and keep it selected (`<gv`) | Nothing |
| `<C-a>` | n | Toggle `true`↔`false` (preserving `TRUE`/`True`/`true` casing) if a boolean comes before the next number on the line; otherwise the normal increment | Increment number |
| `<C-c>` | n | Copy the absolute file path to the system clipboard | Cancel / like `<Esc>` |
| `<C-f>` | n, v, i | Launch `tmux-sessionizer` (tmux), or send F13 to WezTerm | Page forward |
| `<C-e>` | n | Harpoon quick menu | Scroll down one line |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Jump to harpoon slots 1–4 | Mostly unmapped |
| `<C-n>` / `<C-p>` | i | cmp: next/previous completion item | Keyword completion |
| `<C-y>` | i | cmp: confirm selection | Copy char from line above |
| `<S-Tab>` | i | cmp: trigger completion | Nothing |
| `<Tab>` / `<C-Space>` | i | **Unmapped in cmp** (deliberately) | — |
| `<left>` `<right>` `<up>` `<down>` | n | Print "Use h/l/k/j to move!!" | Move cursor |
| `<Esc>` | t | Leave terminal mode (`<C-\><C-n>`) | Send Esc to the program |

### Keymaps — editing & movement

| Key | Mode | Does |
| --- | --- | --- |
| `<leader><Tab>` | n | Indent line and step 4 columns right |
| `<M-j>` | n | Move current line **down** |
| `<M-k>` | n | Move current line **up** |
| `zZ` | n | Scroll so the cursor sits at the left edge (`zszH`) |
| `<leader>l` | n | Show the current line in a floating popup (`q` closes it) |

### Keymaps — clipboard

All use the system clipboard (`"+`).

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>y` / `<leader>Y` | n, v, x | Yank to clipboard |
| `<leader>p` / `<leader>P` | n, v, x | Paste from clipboard |
| `<leader>d` | n, v, x | Delete into clipboard |
| `<leader>c` | n | Copy the absolute file path |

> `<leader>d` shares a prefix with `<leader>df`, `<leader>dg`, `<leader>d1`,
> `<leader>d2` and `<leader>dF`, so in normal mode it waits for `timeoutlen`
> before firing.

### Keymaps — windows & folds

| Key | Mode | Does |
| --- | --- | --- |
| `<M-,>` / `<M-.>` | n | Widen / narrow the window by 5 columns |
| `<M-Up>` / `<M-Down>` | n | Shrink / grow the window height by 5 rows |
| `<leader>zi` | n | Toggle the fold under the cursor |
| `<leader>zM` | n | Set `foldmethod=syntax` and close all folds (for fugitive buffers) |

### Keymaps — files & navigation

| Key | Mode | Does |
| --- | --- | --- |
| `-` | n | Open oil.nvim in the parent directory |
| `<leader>pv` | n | Same as `-` |
| `<leader><C-O>` | n | Open the current file's directory in the OS file manager |
| `<leader>u` | n | Toggle undotree |

### Keymaps — search (Telescope)

`p` = project, `d` = document, `f` = folder. Every grep binding has a visual
variant that seeds the search with the selection.

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>pf` | n, v | Find files across the project (hidden files included) |
| `<leader>pg` | n, v | Live grep across the project (`--hidden`) |
| `<leader>dg` | n, v | Live grep **the current file**. In a quickfix buffer it opens the quickfix picker instead. |
| `<leader>fg` | n, v | Live grep the current file's **folder** |
| `<leader>pt` | n | LSP workspace symbols |
| `<M-\>` | n | LSP document symbols |
| `gd` | n | LSP definitions |
| `<leader>sr` | n | Resume the last picker |
| `<leader><leader>` | n | Grep over all keymaps |
| `<leader>?` | n | Search help tags |

### Keymaps — Harpoon

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>a` | n | Add the current file to the harpoon list |
| `<C-e>` | n | Toggle the harpoon quick menu |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | Jump to harpoon slot 1 / 2 / 3 / 4 |

### Keymaps — LSP

Buffer-local, only in buffers with an attached client.

| Key | Mode | Does |
| --- | --- | --- |
| `K` | n | Hover documentation |
| `<M-Tab>` | n | Hover documentation |
| `H` | n | Signature help |
| `<M-Tab>` | i | Signature help |
| `<C-k>` | i | Signature help |
| `<M-k>` | i | Open the cmp documentation window |
| `<M-\>` | n | Document symbols (Telescope) |
| `<leader>vd` / `grd` | n | Show the diagnostic float |
| `<leader>dF` | n | `:Format` |
| `<leader>pF` | n | `:FormatAll` |
| `<leader>hh` | n | Jump between C/C++ source and header (falls back to `:ClangdSwitchSourceHeader` for other extensions) |
| `<A-o>` | n | Organize imports *(Java buffers only)* |

### Keymaps — diagnostics & quickfix

| Key | Mode | Does |
| --- | --- | --- |
| `[d` / `]d` | n | Previous / next diagnostic |
| `<leader>e` | n | Show the diagnostic float |
| `<leader>q` | n | Diagnostics → location list |
| `<leader>tt` | n | All diagnostics → quickfix, severity-sorted |
| `<leader>te` | n | **Errors only** → quickfix |
| `<leader>td` / `<leader>tde` | n | Current-buffer diagnostics → quickfix |
| `<leader>qf` | n | Dump the quickfix list into a new scratch split, optionally applying a `:%s/…` substitution you are prompted for |

There is also an automatic hook: running `:'<,'>g/pattern/` on a visual range
collects the matching lines into the quickfix list and opens it, instead of the
usual `:global` behaviour.

### Keymaps — git

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>gs` | n | `:Git` (fugitive status) |
| `<leader>gc` | n | `:Git commit` |
| `<leader>gp` | n | `:Git push -u origin` |
| `<leader>gd` | n | `:Gdiff` |
| `<leader>gb` | n | `:Git blame` |
| `<leader>gh` / `gh` | n | Take the **left** side of a merge conflict (`diffget //2`) |
| `<leader>gl` / `gl` | n | Take the **right** side of a merge conflict (`diffget //3`) |
| `<leader>lg` | n | Open lazygit |

### Keymaps — terminals

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>tf` | n, t | Toggle a **floating** terminal (80% of the UI, shares one buffer with `<leader>ts`) |
| `<leader>ts` | n, t | Toggle a **bottom split** terminal, 20 rows |
| `<leader>tn` | n, t | Open a brand-new bottom terminal and remember its channel |
| `<leader>example` | n | Leftover scaffolding — sends `echo 'Hello World'` to the `<leader>tn` terminal. Delays `<leader>e`; see [known issues](#known-collisions--rough-edges). |
| `<Esc>` | t | Leave terminal mode |

### Keymaps — diff view

Two floating scratch buffers you can fill with arbitrary text and diff against
each other — handy for comparing snippets that are not files.

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>d1` | v | Send the selection to diff window **1** |
| `<leader>d2` | v | Send the selection to diff window **2** |
| `<leader>df` | n | Hide the diff windows |
| `:DiffView` | — | Show them |

### Keymaps — debugging (DAP)

| Key | Mode | Does |
| --- | --- | --- |
| `<F5>` | n | Continue (compiles first if no session is running) |
| `<S-F5>` | n | Terminate, and tear down Docker Compose if it was started |
| `<C-S-F5>` | n | Terminate → compile → `run_last` |
| `<F9>` | n | Toggle breakpoint |
| `<S-F9>` | n | Evaluate the expression under the cursor (dap-ui) |
| `<F10>` | n | Step over |
| `<F11>` | n | Step into |
| `<S-F11>` | n | Step out |
| `<leader>Dr` | n | Compile, then re-run the last configuration |
| `<leader>Dc` | n | **Debug class** — pick a test task, compile, run the class |
| `<leader>Dm` | n | **Debug nearest method** — same, for the method under the cursor |
| `<leader>Dl` | n | Pick a test from a list |
| `<leader>Dt` | n | Open the dap-ui console |
| `<leader>Ds` | n | Open stack frames |
| `<leader>Db` | n | List breakpoints ⚠️ (see known issues) |
| `<leader>Dw` | n | Add a watch expression |
| `<leader>Dgc` | n | Run to cursor |
| `<leader>Df` | n | Focus the current frame |

The test-task picker offers `test`, `integrationTest` and `allTests` for Gradle
(or `test` / `verify` for Maven) and marks the ones that need Docker with 🐳.
Files ending in `IT.java` or living under an `/it/` directory skip the picker
and go straight to the integration-test task. dap-ui opens automatically on
launch/attach and closes on exit, dropping you in the console on termination.

### Keymaps — AI assistants

| Key | Mode | Does |
| --- | --- | --- |
| `<leader>ca` | n | Open the Claude Code prompt |
| `<leader>ca` | v | Open the Claude Code prompt with the selection |
| `<leader>oc` | n | Open the OpenCode prompt |
| `<leader>oc` | v | Open the OpenCode prompt with the selection |

### Keymaps — completion (nvim-cmp)

Deliberately minimal: `<Tab>` and `<C-Space>` are **unmapped** so they keep
their normal editing meaning.

| Key | Mode | Does |
| --- | --- | --- |
| `<C-n>` / `<C-p>` | i | Next / previous item |
| `<C-y>` | i | Confirm |
| `<S-Tab>` | i | Trigger completion |
| `<M-k>` | i | Open the documentation window |

Sources: LSP, LuaSnip, path. SQL buffers swap to dadbod-completion + buffer
words. `completeopt` is `menu,menuone,noinsert` — nothing is auto-selected.

### Keymaps — Oil

| Key | Mode | Does |
| --- | --- | --- |
| `<Tab>` | n | Preview the entry under the cursor |
| `<C-v>` | n | Open in a vertical split |
| `<C-h>` | n | **Disabled** (freed for harpoon) |

Hidden files are shown, and simple edits are applied without a confirmation
prompt.

### Keymaps — prompt buffers

Inside the Claude Code / OpenCode floating prompt window:

| Key | Mode | Does |
| --- | --- | --- |
| `<CR>` | n | Submit the prompt |
| `:w`, `:wq`, `:x` | — | Also submit (`wq`/`x` are abbreviated to `w`) |
| `q` / `<Esc>` | n | Close and save the draft for next time |
| `@` | i | Open a Telescope file picker and insert a `` `@path` `` reference |
| `<Space>` | i | Expand a trailing `#buffer` / `#buf` into a reference to the source file |

In the response split, `q` closes the window.

---

## Options that differ from defaults

**Indentation** — `tabstop`/`softtabstop`/`shiftwidth` = 4, `expandtab`,
`smartindent`.

**Display** — `number` + `relativenumber`; `nowrap`; `cursorline`;
`signcolumn=yes`; `scrolloff=10`; `winborder=rounded` (all floats);
`guicursor=""` (block cursor everywhere, including insert mode);
`showmode=false`; `termguicolors`; `breakindent`; the statusline background is
cleared.

**Search** — `ignorecase`; `incsearch`; `hlsearch` (cleared with `<Esc>`);
`inccommand=split` for live `:s` previews.

**Files** — `noswapfile`, `nobackup`, `undofile` with undo history in
`~/.vim/undodir`. `isfname` gains `@-@`.

**Folding** — `foldmethod=expr` with `foldexpr=v:lua.vim.treesitter.foldexpr()`
and `foldlevelstart=99`, so files open fully unfolded but every treesitter node
is foldable.

**Splits** — `splitright`, `splitbelow`.

**Responsiveness** — `updatetime=250`.

**Shell** — zsh on macOS, zsh with `-i -c` on Linux (so interactive aliases
work), PowerShell Core on Windows. `shellquote`/`shellxquote` cleared.

**netrw** — banner off, `browse_split=0`, `winsize=25`, `path+=**` (so `:find`
recurses), `wildmenu` on.

**Colorscheme** — rose-pine (moon variant) with a transparent background;
`LineNr` is orange and the relative numbers around it are white.

**Treesitter** — the `main` branch. Parsers installed on demand: c, cpp,
c_sharp, lua, markdown, markdown_inline, xml, json, java, bash, yaml, vim,
vimdoc, query. Highlighting starts per-buffer via `vim.treesitter.start()`,
indentation uses the experimental treesitter `indentexpr`, and markdown keeps
vim regex highlighting alongside.

**LSP** — servers auto-installed by Mason: `omnisharp`, `lua_ls`, `vtsls`.
jdtls is configured separately (JUnit 4 default test config, runtimes from
SDKMAN). clangd and omnisharp use `*.sln` / `*.csproj` as root markers.
Diagnostic floats are focusable, rounded, and show the source.

## Automatic behaviours

| Trigger | Effect |
| --- | --- |
| Yanking text | Briefly highlights the yanked region |
| Opening a terminal | Hides line numbers and enters insert mode |
| Resuming Neovim (`VimResume`) | Forces a redraw |
| Opening netrw | Moves the cursor onto the file you came from |
| Opening a `git*` filetype | Sets `foldmethod=syntax` |
| Saving a Java buffer | If `:FormatOnSave on`: organize imports + LSP format. Off by default. |
| Saving any LSP buffer | Refreshes codelens (skipped for buffers being batch-formatted) |
| jdtls attaching to a Java buffer | Configures `makeprg`/`errorformat` for gradle |
| Startup | `:MasonUpdate` runs |
| While an AI request runs | `autoread` + periodic `checktime`, so files the agent edits reload automatically |

## Known collisions & rough edges

Documenting these because they are silent — nothing errors, the binding just
does not do what the source suggests.

**`<C-e>` — the harpoon Telescope picker is unreachable.**
`lua/plugins/harpoon.lua` maps `<C-E>` to a Telescope picker and then `<C-e>` to
the quick menu. Neovim normalises both to the same `<C-E>`, so the second
mapping replaces the first. Only the quick menu is reachable.

**`<leader>Dw` is bound twice.** `lua/plugins/dap-ui.lua` maps it to
`Toggle_watches`, then later to `dapui.elements.watches.add()`. The second wins,
so `<leader>Dw` adds a watch. Use `:DapWatch` to open the watches pane.

**`-` is bound three times.** netrw_config.lua, remap.lua and oil.lua all claim
it. Load order means **oil wins**; the netrw and `:Ex` variants are dead.

**`:DapBreakpointsList` / `<leader>Db` throw.** `lua/plugins/dap-ui.lua` calls
`dap.list_breapoints()` — the real function is `dap.list_breakpoints()`.

**`<leader>hh` needs `fzf-lua`, which is not installed.** The source/header
jump works for zero or one match, but errors when several candidates are found.
Only `telescope-fzf-native` is present, which is a different plugin.

**`<C-k>` vs `<C-K>`.** They are the same key to Neovim. Signature help owns
`<C-k>` in insert mode; the cmp docs window was moved to `<M-k>` to avoid
silently clobbering it.

**`<leader>e` is slow to fire.** `lua/plugins/myPlugins/floatingTerminal.lua`
maps `<leader>example`, so `<leader>e` (diagnostic float) has to wait out
`timeoutlen` before Neovim can rule the longer sequence out. Same cause as the
`<leader>d` delay noted in the clipboard section.

**`ftplugin/cpp.lua` assumes a Windows layout.** It builds `makeprg` from a
`D:/src/<project>` path and calls `incredibuild` via `pwsh`; opening a C++ file
outside that layout will error on the `nil` project name.
