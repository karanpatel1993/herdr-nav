# herdr-nav

Find files, search code and debug Java inside [herdr](https://herdr.dev).

A single shell script wiring `fzf`, `ripgrep` and `jdb` into herdr popups,
scoped to the git worktree of the pane you are in.

**One key to remember: `prefix+Space`.** It opens a menu of everything, filtered
as you type. The shortcuts below are the same actions, once you know which you
reach for.

| | |
|---|---|
| `prefix+Space` | **menu — everything, searchable** |
| `prefix+⇧O` | go to file |
| `prefix+⇧C` | go to class |
| `prefix+⇧F` | find in files |
| `prefix+⇧E` | recent files |
| `prefix+⇧V` | project tree |
| `prefix+⇧B` | set breakpoints by browsing a file |
| `prefix+⇧S` | attach `jdb` to a service |
| `prefix+⇧A` | attach `jdb` to every service |

Finding usages, callers and definitions lives in the menu, and on `Ctrl+R` /
`Ctrl+]` once a file is open — which is where you normally want them.

herdr's own `prefix+?` lists them with descriptions, so there is nothing to
memorise.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/install.sh | sh
```

Installs herdr-nav and everything it needs into `~/.local/bin`: `fzf`, `fd`,
`bat`, `ripgrep`, plus `ast-grep` for syntax-aware Java search and `lf` for the
file tree. No admin rights, and nothing already on your `PATH` is touched.

Then:

```sh
herdr-nav keys      # prints bindings — paste into ~/.config/herdr/config.toml
herdr config check && herdr server reload-config
```

`herdr-nav doctor` verifies the setup at any point.

<details>
<summary>Other ways to install</summary>

```sh
# read the installer first
curl -fsSLO https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/install.sh
less install.sh && sh install.sh

# just the script, dependencies from your package manager
curl -fsSLO https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav
chmod +x herdr-nav && ./herdr-nav install
```

`HERDR_NAV_BIN=/somewhere` installs elsewhere; `HERDR_NAV_NO_DEPS=1` skips
dependencies.

</details>

## Navigating

Every search gives you a list. `Enter` on a result opens that file at that line —
where you can search again. That is how you follow a call chain without starting
over.

Tracing who calls `fillDob`:

```
prefix+Space  pick "callers"        → type "fillDob" → every call site
Enter         on a result           → opens that file, on that line
Ctrl+R        pick an identifier    → every caller of it
Enter                               → opens that one
Esc                                 → back one step
```

### Keys

Once a list of results is open:

| | |
|---|---|
| `Enter` | open the file there |
| `Ctrl+P` | send `path:line` to your pane |
| `Ctrl+T` | set a breakpoint there |
| `Ctrl+V` | view the file |
| `Alt+W` | resize the preview |

Once a file is open:

| | |
|---|---|
| `Ctrl+R` | callers or usages of an identifier on this line |
| `Ctrl+]` | definition of an identifier on this line |
| `Tab` | mark a line — mark several, then `Enter` sets them all |
| `Enter` | set a breakpoint on the marked lines |

Click to select and scroll with the wheel anywhere, including the preview.

## Debugging

Attach a Java debugger to a running service and read variables, without leaving
herdr.

1. `prefix+⇧S` — pick a running service. `jdb` attaches in a new pane.
2. `prefix+⇧B` — pick a file, `Tab` the lines you want, `Enter`. The breakpoint
   commands are typed into the debugger pane.
3. Press `Enter` in that pane to arm them, then `cont` to run.

| | |
|---|---|
| `prefix+⇧S` | attach to one service |
| `prefix+⇧A` | attach to every running service, one pane each |
| `prefix+⇧B` | pick a file and set breakpoints in it |

To print the variables automatically every time a breakpoint hits, add this to
`~/.jdbrc`:

```
monitor where
monitor locals
```

If a service is running code built from a different worktree than your pane, the
service list says so — otherwise your line numbers point at the wrong lines.

## Configuration

Optional, `~/.config/herdr-nav/config` — see [`config.example`](config.example).

| | default | |
|---|---|---|
| `HERDR_NAV_DEBUG_PORTS` | — | `"5005:api 5019:worker"` — names your services |
| `HERDR_NAV_OPEN` | `pane` | `pane`, `idea` or `print` |
| `HERDR_NAV_MIN_QUERY` | `3` | ignore shorter live-search queries |
| `HERDR_NAV_MAX_HITS` | `20000` | cap on results |
| `HERDR_NAV_BIN` | — | where `install` puts the script |

## Limits

With `ast-grep` installed, Java search parses the code — a name inside a comment,
a string, or an unrelated word cannot match. Without it, the same searches fall
back to regex and are noisier. `doctor` says which engine is active.

Either way it is **syntax-aware, not type-aware**: it cannot tell your `status`
from another class's `status`, overloads look alike, and interface dispatch,
reflection, Lombok and jar code are invisible. **Zero results means "not found",
not "dead code".**

Scope a local variable to its file — repo-wide, a short name is mostly noise:

```sh
herdr-nav usages uc path/to/TheFile.java
```

Linux and macOS; Windows needs WSL. [NOTES.md](NOTES.md) has the details.

MIT
