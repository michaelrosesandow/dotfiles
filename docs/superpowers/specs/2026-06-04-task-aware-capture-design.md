# Task-aware quick-capture

**Date:** 2026-06-04
**Builds on:** `2026-06-02-obsidian-nvim-design.md` (the `oc` / `<leader>oc` capture).
**Repos/paths:**
- Capture logic: `~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua` (git: `~/dotfiles`).
- Daily Note template: `~/claude-code-time/mrs/_Templates/Daily Note.md` (vault; not a git repo).
- `good morning` logic: `~/claude-code-time/mrs/CLAUDE.md` (vault; not a git repo).

## Goal

Let quick-capture distinguish a *task* ("remember to do X later") from a *note*.
Tasks should end up as real `01 - Tasks/*.md` files integrated with the existing
`good morning` carry-forward — not as inert lines in Scratch Pad. Achieved by
reusing two patterns the vault already has: the capture pipeline (`M.append`) and
the `new task` inference logic.

## Key constraint

`oc` runs a bare `nvim --headless -u NONE` with **no LLM**, and `<leader>oc` is pure
Lua. Neither can infer due date / type / project. So:
- The **signal** for "this is a task" must be a dumb, mechanical text check.
- The **inference + filing** (the LLM work) happens later, at `good morning` time.

## Behavior

### 1. Capture routing (in `M.append`, shared by terminal `oc` and `<leader>oc`)

Detect a leading **`todo`** or **`task`** keyword, case-insensitive, optional colon,
requiring non-empty text after it:
- Matches → **task**: strip the keyword, insert under `## Inbox` of today's daily
  note as a checkbox: `- [ ] <title>`.
- No match → **note** (unchanged): insert under `## Scratch Pad` as `- <text>`.
- Guard: a bare `todo` / `task` with nothing after it is treated as a plain note
  (no empty tasks created).

Examples:
- `oc todo talk to John about compliance` → `## Inbox`: `- [ ] talk to John about compliance`
- `oc task: review Q3 deck` → `## Inbox`: `- [ ] review Q3 deck`
- `oc TODO ping Eric` → `## Inbox`: `- [ ] ping Eric`
- `oc that scattered-thoughts article` → `## Scratch Pad`: `- that scattered-thoughts article`
- `oc todo` (nothing after) → `## Scratch Pad`: `- todo`

Detection lives in exactly one place (`M.append`) so terminal and nvim are identical.
The `oc` shell function is **unchanged** — it already routes through this Lua.

The section-insertion helper is generalized so it can target either `## Inbox` or
`## Scratch Pad` (insert at end of the named section, after any hint/existing items
and before trailing blanks / the next `## ` heading / EOF; create the section if
absent). Both the live-buffer and on-disk capture paths use it, as today.

### 2. Daily Note template

Add a `## Inbox` section immediately above `## Scratch Pad`, with a hint comment:

```markdown
## Inbox
<!-- Quick-captured tasks (e.g. `oc todo ...`). `good morning` files these into 01 - Tasks/ and clears this section. -->
```

`ensure_today` already renders today's note from this template when missing, so a
freshly-created note will have the `## Inbox` section.

### 3. `good morning` promotion (vault `CLAUDE.md`)

Add a promotion step and supporting edits so Inbox items become real task files:

- **New step — Promote Inbox** (runs during the morning flow, BEFORE the Step 6
  `01 - Tasks/` scan, AFTER Step 3a auto-close): read the **prior note's `## Inbox`**.
  For each unchecked `- [ ]` item, run the existing **New Task Logic** (title
  cleanup, due-date-from-natural-language, project/owner/type inference) to create
  `01 - Tasks/{Title}.md` with `status: open`. **Dedupe by title** — if a task file
  of that title already exists, skip (makes the step idempotent across same-day
  refresh runs). Do **not** carry the raw Inbox text forward; the new file is
  surfaced by the existing Step 6 scan into the correct section (Overdue / Due Today
  / Due This Week / In Progress Ideas) by its due date.
- **Step 2 (refresh mode):** add `## Inbox` to the list of user-owned sections
  preserved verbatim (alongside Scratch Pad / Decisions / EOD Reflection), so items
  captured after the morning run aren't wiped by a re-run. (Promotion targets the
  *prior* note's inbox, so today's inbox is left intact until tomorrow.)
- **Step 4 (extraction):** explicitly note that `## Inbox` is handled by the
  promotion step and is NOT also extracted as free-text here (avoid double-processing).
- **Step 8 (confirmation):** report how many Inbox items were promoted to task files.

### Timing rule

A task captured Tuesday afternoon appears as a checkbox in Tuesday's Inbox
immediately, and is filed as `01 - Tasks/{Title}.md` on Wednesday's `good morning`.
Filing requires inference, which only runs at morning (LLM) time.

## Out of scope

- LLM inference inside `oc` / `<leader>oc` (architecturally impossible — no LLM).
- A separate task-capture command or keymap (decided against; keyword prefix only).
- Same-day / on-capture filing.
- Promoting items the user typed into Scratch Pad (only `## Inbox` is promoted).

## Acceptance criteria

- `oc todo X` and `oc task: X` and `oc TODO X` append `- [ ] X` under today's
  `## Inbox` (keyword stripped), creating the section if missing, focus preserved.
- `oc X` (no keyword) still appends `- X` under `## Scratch Pad`.
- `oc todo` (no trailing text) is treated as a note, not an empty task.
- `<leader>oc` in nvim exhibits identical routing (same `M.append`).
- The Daily Note template contains `## Inbox` above `## Scratch Pad`.
- `good morning`'s `CLAUDE.md` documents: the Promote-Inbox step (with dedupe-by-title
  and "before Step 6" ordering), `## Inbox` in the refresh preserve-list, the Step 4
  exclusion note, and the Step 8 confirmation line.

## Verification

- Headless: run `M.append` with task and note inputs against a temp note; assert the
  task lands under `## Inbox` as `- [ ] ...` (keyword stripped) and the note lands
  under `## Scratch Pad` as `- ...`. Cover the colon, casing, and bare-keyword cases.
- Manual (interactive, user): `oc todo ...` from terminal and `<leader>oc` in nvim;
  confirm placement. `good morning` promotion is verified the next time it runs in
  Cowork (the LLM step), not headlessly here.
