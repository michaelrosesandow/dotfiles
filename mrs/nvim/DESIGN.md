# Neovim config — design

_2026-06-01. Hand-rolled revival of the old `mrs/vim` (dein/deoplete) setup._

## Goal

A snappy, good-looking Neovim that is **excellent at Markdown and notes**, navigates
files/notes fast, and has nice syntax highlighting for the occasional glance at code —
**without** the IDE machinery (LSP, async completion, linting) of the old config.

Context: coding agents write the actual code now; hand-editing is rare. So the old
heavy stack (YouCompleteMe, deoplete, LanguageClient, ALE, syntastic) is dropped, not
ported.

## Decisions

- **Editor:** Neovim (install via Homebrew). Old Vim config stays untouched in `mrs/vim/`.
- **Structure:** hand-rolled, modular Lua — mirrors the old numbered `config/*.vim` style.
- **Plugin manager:** `lazy.nvim` (replaces dein).
- **Markdown:** in-buffer rendering (`render-markdown.nvim`) **and** browser live-preview
  (`markdown-preview.nvim`).
- **Repo home:** this dotfiles repo, under `mrs/nvim/`. `~/.config/nvim` symlinks here.
- **No LSP/completion in v1** — easy to add one language later if ever needed.

## Layout

```
mrs/nvim/                      ->  symlinked to ~/.config/nvim
  init.lua                     -- leader, bootstrap, require modules
  lua/config/
    options.lua                -- numbers, scrolloff, clipboard, tabs, termguicolors
    keymaps.lua                -- muscle-memory mappings (below)
    lazy.lua                   -- bootstrap lazy.nvim
  lua/plugins/
    colorscheme.lua            -- solarized-family, dark
    ui.lua                     -- lualine + which-key
    editor.lua                 -- telescope, treesitter, nvim-surround, Comment.nvim, tmux-navigator
    markdown.lua               -- render-markdown.nvim + markdown-preview.nvim
```

## Plugin stack (modern replacements)

| Old | New | Why |
|---|---|---|
| dein.vim | lazy.nvim | current standard; lockfile, lazy-loading |
| airline / powerline | lualine.nvim | lighter, Lua-native |
| vim-polyglot | nvim-treesitter | real highlighting for md/py/sql/js/lua/bash |
| ctrlp / fzy | telescope.nvim | fuzzy find + live-grep (uses ripgrep) |
| commentary | Comment.nvim | `gcc` toggle |
| vim-surround | nvim-surround | maintained, same muscle memory |
| vim-tmux-navigator | (kept) | still maintained |
| — | render-markdown.nvim | in-buffer md rendering |
| — | markdown-preview.nvim | browser live-preview |
| — | which-key.nvim | shows leader mappings while typing |

Dropped: YouCompleteMe, deoplete, LanguageClient-neovim, ALE, syntastic, neosnippet,
dbext, vimwiki, Vundle.

## Keybindings (preserved from old config)

- `Space` leader
- `jk` / `kj` → `<Esc>` (insert)
- `;` → `:`
- `j` / `k` → `gj` / `gk` (move by visual line)
- `Ctrl-h/j/k/l` → window navigation (integrates with tmux-navigator)
- `0` → `^`
- `<leader>so` / `<leader>vr` → source / edit config
- New: `<leader>ff` find files, `<leader>fg` live-grep, `<leader>mp` toggle browser preview

## Notes workflow

Lightweight: telescope find/grep, made pleasant by render-markdown. Not reviving vimwiki.
(An obsidian.nvim + blink.cmp vault integration was tried and removed.)

## Dependencies (Homebrew)

- `neovim` (0.12+), `ripgrep`
- `tree-sitter-cli` — nvim-treesitter's `main` branch compiles parsers with it
- `node` — markdown-preview.nvim builds its browser server locally with yarn
- A Nerd Font (installed: `font-jetbrains-mono-nerd-font`) for statusline/markdown icons.
  Set your terminal's font to "JetBrainsMono Nerd Font" for glyphs to show.

Note: nvim-treesitter is pinned to the `main` branch (the `master` branch is broken on
Neovim 0.12). Neovim already bundles the `markdown`/`markdown_inline` parsers, so markdown
renders without any parser install; code-language parsers compile on first launch.

## Out of scope

- Running SQL/queries from the editor (needs a PAT that isn't available).
- LSP / autocompletion / linting.
