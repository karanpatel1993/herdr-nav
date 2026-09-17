# Changelog

## 0.2.0

**Search is syntax-aware.** Java `callers`, `usages` and `def` run through
`ast-grep`, so a name inside a comment, a string, or an unrelated word no longer
matches. Falls back to regex when `ast-grep` is absent; `doctor` says which
engine is live.

**Navigation is a loop.** `Enter` on a result opens that file at that line, where
`Ctrl+R` (callers/usages) and `Ctrl+]` (definition) search again. `Esc` steps
back, `Ctrl+Q` closes the popup from any depth. The file list is syntax
highlighted.

**Setup is automatic.** `herdr-nav setup` writes the keybindings and reloads
herdr; `setkey <action> <key>` changes one; `keys` shows a reviewable table with
action names. Bindings are written between markers, so re-running replaces them
rather than duplicating.

**New commands.** `install`, `install-deps`, `update`, `uninstall`, `help`, and a
`prefix+Space` menu covering every action.

**Install is one command.** `install.sh` fetches the tool and its dependencies —
`fzf`, `fd`, `bat`, `ripgrep`, `ast-grep`, `lf` — into `~/.local/bin`, no admin
rights needed.

**Fixes**
- `update` renames into place; rewriting a running script corrupted it mid-execution
- jump-to-line uses fzf's `load` event; `start` fires before the list exists
- `install-deps` handles zip assets, the executable bit, and API rate limiting
- macOS and BSD: `lsof`/`ps`/`tail -r` instead of `ss`/`/proc`/`tac`
- live search ignores queries under 3 characters and caps results

## 0.1.0

Initial release: file, class and text search, project tree, recent files,
breakpoint browser, and `jdb` attach for one or every service.
