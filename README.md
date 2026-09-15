# herdr-nav

Find files, search code and debug Java inside [herdr](https://herdr.dev) — so
your agents and your code live in one place.

A single shell script wiring `fzf`, `ripgrep` and `jdb` into herdr popups,
scoped automatically to the git worktree of the pane you are in.

| | |
|---|---|
| `prefix+⇧O` | go to file |
| `prefix+⇧C` | go to class |
| `prefix+⇧F` | find in files |
| `prefix+⇧U` | find usages of a variable |
| `prefix+⇧I` | find callers of a method |
| `prefix+⇧M` | go to definition |
| `prefix+⇧E` | recent files |
| `prefix+⇧V` | project tree |
| `prefix+⇧B` | set breakpoints by browsing a file |
| `prefix+⇧S` | attach `jdb` to a service |
| `prefix+⇧A` | attach `jdb` to every service |

## Install

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav \
  -o ~/.local/bin/herdr-nav && chmod +x ~/.local/bin/herdr-nav

# if ~/.local/bin isn't on your PATH yet:
export PATH="$HOME/.local/bin:$PATH"     # add to ~/.zshrc or ~/.bashrc

herdr-nav doctor    # what's missing and how to get it
herdr-nav keys      # prints bindings — paste into ~/.config/herdr/config.toml
herdr config check && herdr server reload-config
```

`herdr-nav keys` skips any key you already use and tells you where it moved
things. It prints; you paste. It never edits your config.

Needs `fzf`, `fd`, `bat`, `ripgrep`. `doctor` prints the install command for your
package manager, or `herdr-nav install-deps` fetches static builds into
`~/.local/bin` with no sudo.

## Navigating

Results are not dead ends — `Enter` takes you there and you keep going:

```
prefix+⇧I    Callers of: fillDob
Enter        → lands in that file, on that line
Ctrl+R       → pick an identifier → its callers (or usages)
Ctrl+]       → pick an identifier → its definition
Esc          → back one step
```

`Enter` descends, `Esc` climbs. The mouse works everywhere — click to select,
scroll the list and the preview.

**In a results list:** `Ctrl+P` send `path:line` to your pane · `Ctrl+T` breakpoint ·
`Ctrl+V` view · `Alt+W` resize preview.
**In the line browser:** `Tab` mark several lines, so one pass sets many breakpoints.

## Debugging

`prefix+⇧S` picks from live JDWP ports and attaches `jdb` with your source tree
on the sourcepath. `prefix+⇧A` opens one pane per service — JDWP allows a single
debugger per JVM, so a multi-service trace needs a session each.

`prefix+⇧B` browses a file and turns marked lines into `stop at` commands.

For variables printed on every stop, put this in `~/.jdbrc`:

```
monitor where
monitor locals
```

The port picker warns when a JVM was built from a **different worktree** than
your pane — line numbers only match the code that is actually running.

## Configuration

Optional, `~/.config/herdr-nav/config` — see [`config.example`](config.example).

| | default | |
|---|---|---|
| `HERDR_NAV_DEBUG_PORTS` | — | `"5005:api 5019:worker"` — names your services |
| `HERDR_NAV_OPEN` | `pane` | `pane`, `idea` or `print` |
| `HERDR_NAV_MIN_QUERY` | `3` | ignore shorter live-search queries |
| `HERDR_NAV_MAX_HITS` | `20000` | cap on results |

## Limits

**Search is text, not semantics.** It cannot tell your `status` from another
class's `status`. Overloads look alike, interface dispatch and reflection are
invisible, and Lombok or jar code has no source to find. **Zero results means
"not found textually", never "this is dead code".**

For a local variable, scope it to its file — repo-wide, a short name is mostly
noise:

```sh
herdr-nav usages uc path/to/TheFile.java
```

**Linux** and **macOS** are supported; Windows needs WSL. Platform is chosen once
from `uname`, and `doctor` shows which. See [NOTES.md](NOTES.md) for the details
and the two herdr gotchas worth knowing.

MIT
