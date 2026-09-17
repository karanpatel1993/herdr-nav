# Notes

Detail that would clutter the README. Read it if something surprises you.

## Releasing

Every published change bumps `VERSION` in `herdr-nav`, or `update` reports
"0.1.0 -> 0.1.0" and tells the user nothing.

```sh
sed -i 's/^VERSION=.*/VERSION=0.3.0/' herdr-nav   # bump
$EDITOR CHANGELOG.md                              # what changed, in user terms
git commit -am "release 0.3.0" && git push
git tag -a v0.3.0 -m "herdr-nav 0.3.0" && git push origin v0.3.0
gh release create v0.3.0 --notes-from-tag
```

Patch for fixes, minor for new commands or keys. `update` compares the running
version with the fetched one and says which way it moved.

## Two herdr gotchas

**Bindings need an absolute path.** The herdr server runs with a bare `PATH` —
no `~/.local/bin`, no version-manager bins. `herdr config check` reports `ok` for
a bare command name, which then fails silently at keypress time, with no error
anywhere. `herdr-nav keys` emits absolute paths for exactly this reason.

**Under `herdr --remote`, the client uses your *local* keybindings.** Bindings
that live in the remote config are only reachable *after* the prefix, because
the server resolves post-prefix keys. So `prefix+X` works and a bare `ctrl+alt+X`
chord does not — unless you attach with `--remote-keybindings server`.

## Why shift, not option

Alt/option arrives as `ESC` + `<key>`: two bytes. Over an SSH attach they can
land in separate packets, and the first press is swallowed while the terminal
waits to see whether that `ESC` was a bare Escape. Shift is carried in the
character itself, so there is no timing window.

The same reasoning applies inside fzf, where `Ctrl+T` and `Ctrl+R` are the
reliable keys and their `Alt` equivalents are kept only as aliases.

## Platform handling

Chosen once from `uname`, never re-probed:

| | port lookup | process args | reverse |
|---|---|---|---|
| Linux | `ss` | `/proc/<pid>/cmdline` | `tac` |
| macOS / BSD | `lsof` | `ps -o command=` | `tail -r` |

Each platform has its own implementation rather than a fallback chain, and the
tool it needs is checked before any debugger command runs — a missing `ss` or
`lsof` fails with the reason instead of quietly taking another path. Only the
debugger needs it; search and navigation do not.

`herdr-nav doctor` prints what is active:

```
platform
  detected     linux (Linux)
  port lookup  ss (present)
```

macOS ships bash 3.2, so the script avoids what breaks there — notably empty
array expansion under `set -u`.

## Search performance

There is nothing to index. Ripgrep answers a real query over ~55k files in about
0.12s. What hurts is the first keystroke: a one-character query can match
millions of lines, which fzf then has to ingest.

| query | without a guard | with |
|---|---|---|
| `e` | 6,133,175 lines, 0.58s | 0 lines, 0.01s |
| `public` | 112,874 lines | 20,000 lines, 0.06s |
| `esDirectory` | 0.12s | 0.13s |

Hence `HERDR_NAV_MIN_QUERY` (default 3) and `HERDR_NAV_MAX_HITS` (default 20000).

## Search engines

With `ast-grep` and `jq` installed, Java searches run against a parsed syntax
tree. Without them, they fall back to regex. Measured on a 55k-file monorepo:

| query | ast-grep | regex |
|---|---|---|
| `usages uc` | 217 | 457 |
| `def ProfileConsumer` | 1 | 2 |

The regex extras are comments, string literals and unrelated words. ast-grep
costs about 3s across the whole repo against ripgrep's 0.12s — fine for an
on-demand query, which is why live `grep` still uses ripgrep.

A bare call and a qualified call are different syntax nodes, so `callers` runs
two patterns — `name($$$A)` and `$O.name($$$A)` — and merges them. Definitions
use a rule matching node *kind* (`method_declaration`, `class_declaration`, …)
plus the name, which is why they are exact.

## How callers and definitions are told apart

A Java declaration puts a modifier or a return type immediately before the name;
a call site does not. `callers` matches `name(` and subtracts anything matching
the declaration shape; `def` keeps only the declarations, which is why it returns
the interface method *and* every override in one list.

Accurate for distinctive names, noisy for short ones:

| | `usages` | `callers` |
|---|---|---|
| `fillDob` | 2 (call + declaration) | 1 |
| `getNormalizedString` | 84 | 74 |

## Suspend-all is not configurable

jdb suspends every thread on a breakpoint. Measured on a two-thread JVM: while
one thread sat at a breakpoint, the other produced no output at all over five
seconds. There is no per-breakpoint suspend policy — `stop at` and `stop in`
always suspend everything.

For a web app that means the server stops accepting requests entirely until you
`cont`. Cancelling the client request changes nothing. If the prompt is
unresponsive because the thread it points at died with the request, `threads`,
then `thread <id>`, then `cont`.

IntelliJ can suspend a single thread and keep serving. If you need that, attach
IntelliJ to the same port instead.

## Breakpoints

Marked lines become `stop at <fqcn>:<line>` commands, joined so that every one
but the last executes on arrival — you press the final Enter. Nothing fires in a
pane that isn't a debugger without you seeing it first.

Line breakpoints drift when you edit the file. `stop in <class>.<method>` does
not, and is often the better choice.

## No ⌘-click

Terminal mouse reports carry the button, the position and Control — there is no
bit for Command, so a terminal cannot distinguish ⌘-click from a plain click.
herdr's own link handlers use Ctrl+click for this reason, and they only fire on
URLs, not arbitrary source identifiers. `Ctrl+R` on a clicked line is the
equivalent here.
