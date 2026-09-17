# Changelog

## 0.3.0

Installable as a herdr plugin: `herdr plugin install karanpatel1993/herdr-nav`.
The manifest declares the nine pickers as pane entrypoints, so herdr owns the
popup geometry, and a build step brings the dependencies and links the script
onto `PATH` so every subcommand still works by name.

Keys and commands are identical either way. Two differ, because under a plugin
the directory belongs to herdr: `update` points at `herdr plugin install`
rather than rewriting itself, and `uninstall` removes the bindings, config and
symlink but leaves the checkout to `herdr plugin uninstall`.

Which mode is in play is read from where the script sits -- a marker the build
step drops -- not from the environment. `HERDR_PLUGIN_ID` is set only for
commands herdr launches, so it is absent at a shell prompt, which is exactly
where `update` must not guess wrong.

The standalone `curl | sh` install is unchanged.

## 0.2.7

Bindings are written `Shift+O` rather than `⇧O` in the README and in
`herdr-nav help`. The glyph sat oddly beside the spelled-out `Ctrl+` and `Alt+`
alongside it, and renders narrow enough on some terminals to read as a smudge.

## 0.2.6

Trimmed the README's debugging notes to the fact and the fix; the measurement,
the dead-thread recovery and the IntelliJ comparison moved to NOTES.md.

## 0.2.5

An open file has always been searchable by typing — it is an fzf picker — but
nothing said so. The header now reads "type to search", and `Ctrl+U` clears the
filter to get the whole file back.

## 0.2.4

Documented the jdb commands you need once attached — `cont`, `next`, `step`,
`dump`, `print`, `up`/`down`, `clear`, `threads` — in both the README and
`herdr-nav help`. Also documented two things that read as bugs and are not: a
variable assigned on the line you are stopped at is still empty until you
`next`, and a breakpoint suspends every thread, so a web server stops accepting
requests until you `cont`.

## 0.2.3

The suggested `~/.jdbrc` no longer includes `monitor where`. On a servlet app
that prints 110 frames of Jetty and Struts on every breakpoint. It now suggests
`monitor locals` + `monitor list`, which shows the variables and the surrounding
source with the current line marked.

## 0.2.2

**Attaching a debugger works.** Picking a service from the list closed the pane
instead of attaching. `set -o pipefail` is on, and the port filter's last
iteration returns non-zero whenever the highest listening port is not a debug
port — which the caller read as "cancelled" and exited silently.

## 0.2.1

**The debugger list only shows real debug ports.** It used to offer every
listening port — Redis, Mongo, IntelliJ — and `jdb` simply hangs against those.
It now checks that the port is the one a JVM's `jdwp` agent is listening on, so
an app's HTTP port on the same process is no longer offered either.

**The worktree warning is accurate.** It derived the tree from the last
directory of whatever path it found, so a service under
`.../ultron/core/nb/dist/conf/` was reported as "conf" and flagged as a
mismatch every time. It now resolves the process's real git worktree root.

Unconfigured ports show the jar or main class instead of "?".

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
