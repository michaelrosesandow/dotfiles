# obsidian.nvim — capture + navigation

**Date:** 2026-06-02
**Repo:** `~/dotfiles` (nvim config at `mrs/nvim/`, symlinked to `~/.config/nvim`)
**Vault:** `~/claude-code-time/mrs` (Obsidian "work OS", PARA structure)

## Goal

Reduce capture friction and make the vault fast to navigate from the terminal, to
reinforce the habit of actually using it. Neovim is a **capture + navigation**
on-ramp; the Obsidian desktop app (and the Cowork `good morning` automation) remain
the system of record. Restructuring work (moving/merging daily-note content into
project notes) is intentionally **out of scope** here — it stays with the app's
`note-composer` plugin and Claude/Cowork.

## Non-goals (decided, do not build)

- Template *insertion* as a workflow, frontmatter helpers.
- Vault-wide link rename/refactor.
- Tag panes / tag-driven workflows.
- Extract/merge selection → project note (use app note-composer or Claude/Cowork).
- A standalone completion engine (nvim-cmp / blink.cmp) — not needed; obsidian.nvim
  ships built-in in-process-LSP completion for `[[` and `#`.

## Plugin

- `obsidian-nvim/obsidian.nvim` (the maintained fork; the original `epwalsh/…` is archived).
- New file: `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua`.
- Dependencies already installed: `telescope.nvim`, `plenary.nvim`, `nvim-web-devicons`.
  **No new heavy dependency.**
- Lazy-load on the vault path (`event`/`ft`), markdown filetype, and the `<leader>o`
  keymaps + `:Obsidian` command.

## Conform to the app's conventions (the footguns)

These exist so nvim reads/writes the *same* files the app and automation already use,
rather than creating a parallel, mis-named set.

1. **Workspace:** single workspace, path `~/claude-code-time/mrs`.
2. **Daily notes:**
   - `folder = "00 - Daily Notes"`
   - `date_format = "%Y-%m-%d %A"` → `2026-03-31 Tuesday` (matches existing files).
     obsidian.nvim uses Lua `strftime`, **not** the app's moment format
     `YYYY-MM-DD dddd`. This is the single highest-risk line — getting it wrong
     spawns duplicate, mis-named daily notes.
   - `template = "Daily Note.md"` (from `_Templates/`), so a not-yet-created "today"
     opened in nvim matches the real structure instead of a bare stub.
3. **Human-readable filenames:** override `note_id_func` to return the sanitized
   title (e.g. `Foo Bar.md`), matching `06 - People/` etc. — not the default
   Zettelkasten timestamp IDs.
4. **Plain wikilinks:** emit `[[Note Name]]` (no `id|alias` form), matching what the
   app and automation write. Configure `preferred_link_style = "wiki"` and a
   `wiki_link_func` that produces title-only links.
5. **New ad-hoc notes:** land in `04 - Notes/`
   (`new_notes_location = "notes_subdir"`, `notes_subdir = "04 - Notes"`).
6. **Templates folder:** `templates.folder = "_Templates"` (needed for daily-note
   template substitution; no insertion keymaps added).

## Don't fight render-markdown

- obsidian.nvim has its own in-buffer renderer that collides with the existing
  `render-markdown.nvim`. Set `ui = { enable = false }`.
- Set `conceallevel = 2` for markdown buffers so links/formatting conceal cleanly
  under render-markdown.

## Keymaps — `<leader>o` ("obsidian") prefix

**Capture (the habit goal):**

- `<leader>oc` — **quick capture.** `vim.ui.input` prompt → append the entered line
  under the `## Scratch Pad` heading of today's daily note, creating today's note
  from the Daily Note template if it does not yet exist. Returns to the current
  buffer; does not steal the editing context. Scratch Pad is chosen because it is a
  user-owned section the re-runnable `good morning` automation does not overwrite.
- `<leader>ot` — open today (`:Obsidian today`)
- `<leader>oy` — yesterday (`:Obsidian today -1`)
- `<leader>on` — new note (`:Obsidian new`)

**Navigation:**

- `<leader>os` — quick switch / jump to any note by name (telescope)
- `<leader>og` — search vault contents (telescope grep over the vault)
- `<leader>ob` — backlinks for current note
- `<leader>of` — follow `[[link]]` under cursor (creates if missing)
- `[[` and `#` — built-in autocompletion as you type

Register the `<leader>o` group label with which-key (already installed) so the
prefix is discoverable.

## Fix to existing config

- `editor.lua`: `<leader>fn` ("Find notes") currently points at a nonexistent
  `~/notes`. Repoint it to the vault `~/claude-code-time/mrs` so telescope
  file-find works alongside obsidian's switcher.

## Acceptance criteria

- `<leader>oc` on any buffer prompts, appends under `## Scratch Pad` of today's
  correctly-named daily note (`YYYY-MM-DD <Weekday>.md` in `00 - Daily Notes/`),
  and leaves the original buffer focused.
- `<leader>os` lists vault notes via telescope; selecting one opens it.
- `<leader>of` on a `[[Note]]` opens that note (creating it in the right place if
  missing).
- Typing `[[` offers note-name completion with no extra completion plugin.
- A new note created via `<leader>on` has a human-readable title filename and a
  `[[Plain Title]]`-style link, not a timestamp ID.
- render-markdown still renders markdown normally (no double-rendering / conflict).
- `<leader>fn` opens telescope rooted at the vault.

## Verification

Manual, since this is editor config:

1. From a scratch buffer, `<leader>oc`, enter "test capture", confirm the line lands
   under `## Scratch Pad` in today's daily note and the original buffer is refocused.
2. `<leader>os` → pick a known note (e.g. a `06 - People/` entry) → opens.
3. Place cursor on an existing `[[...]]` link, `<leader>of` → opens the target.
4. Type `[[` in a note → completion menu appears.
5. `<leader>on` → name it → check filename and any inserted link format.
6. Confirm render-markdown still styles headings/checkboxes.
