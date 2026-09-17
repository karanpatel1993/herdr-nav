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
| `prefix+Shift+O` | go to file |
| `prefix+Shift+C` | go to class |
| `prefix+Shift+F` | find in files |
| `prefix+Shift+E` | recent files |
| `prefix+Shift+V` | project tree |
| `prefix+Shift+B` | set breakpoints by browsing a file |
| `prefix+Shift+S` | attach `jdb` to a service |
| `prefix+Shift+A` | attach `jdb` to every service |

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
herdr-nav keys      # review the bindings it will add
herdr-nav setup     # add them and reload
```

`setup` writes them into `~/.config/herdr/config.toml` between markers, backs the
file up first, and skips any key you already use. Re-running replaces its own
block rather than adding a second one.

To change one, name the action and the key you want:

```sh
herdr-nav setkey grep prefix+shift+g
```

It records the choice and re-applies everything in one step. `herdr-nav keys`
lists the action name next to every binding, so you can read off the one you
want to change.

`herdr-nav help` is the full manual — every key, the debugging flow, and the
`jdb` commands. It is also in the menu, so `prefix+Space` → `help` works mid-task.

`herdr-nav doctor` verifies everything at any point.

### Update

```sh
herdr-nav update
```

Replaces the script in place. Keybindings point at the path, not the contents,
so there is no need to re-run `setup`.

### Uninstall

```sh
herdr-nav uninstall
```

Removes the keybindings from your herdr config, the herdr-nav config and state,
and the script. It lists what it will delete and asks first; `--yes` skips the
prompt. Your other herdr bindings, your config backups, and the search tools
(`fzf`, `ripgrep`, …) are left alone.

<details>
<summary>Other ways to install</summary>

```sh
# read the installer first
curl -fsSLO https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/install.sh
less install.sh && sh install.sh

# just the script
curl -fsSLO https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav
chmod +x herdr-nav && ./herdr-nav install
herdr-nav install-deps      # or install fzf/fd/bat/ripgrep/ast-grep yourself
```

`HERDR_NAV_BIN=/somewhere` installs elsewhere; `HERDR_NAV_NO_DEPS=1` skips
dependencies.

</details>

## Navigating

`Enter` always opens the file. Once a file is open, `Ctrl+R` and `Ctrl+]` search
again from there — that is how you follow a call chain without starting over.

Say you have a file open and want to know who calls a method in it:

```
prefix+Shift+O  type "ProfileConsumer" → Enter    opens the file
                move to the line you care about
Ctrl+R          pick the method name              every caller of it
Enter           on a result                       opens that file, on that line
Ctrl+R          again, from there                 keep following the chain
Esc                                               back one step
```

`Ctrl+R` gives callers for a method and usages for a variable — it decides from
the line. `Ctrl+]` jumps to where the identifier is defined.

If you already know the name, skip the file: `prefix+Space` → `callers` → type it.

### Keys

Once a list of results is open:

| | |
|---|---|
| `Enter` | open the file there |
| `Ctrl+P` | send `path:line` to your pane |
| `Ctrl+T` | set a breakpoint there |
| `Ctrl+V` | view the file |
| `Alt+W` | resize the preview |
| `Esc` / `Ctrl+Q` | back one step / close the popup entirely |

Once a file is open:

| | |
|---|---|
| *type* | filters the lines — the in-file search |
| `Ctrl+U` | clear the filter, back to the whole file |
| `Ctrl+R` | callers or usages of an identifier on this line |
| `Ctrl+]` | definition of an identifier on this line |
| `Tab` | mark a line — mark several, then `Enter` sets them all |
| `Enter` | set a breakpoint on the marked lines |

Click to select and scroll with the wheel anywhere, including the preview.

## Debugging

Attach a Java debugger to a running service and read variables, without leaving
herdr.

1. `prefix+Shift+S` — pick a running service. `jdb` attaches in a new pane.
2. `prefix+Shift+B` — pick a file, `Tab` the lines you want, `Enter`. The breakpoint
   commands are typed into the debugger pane.
3. Press `Enter` in that pane to arm them, then `cont` to run.

| | |
|---|---|
| `prefix+Shift+S` | attach to one service |
| `prefix+Shift+A` | attach to every running service, one pane each |
| `prefix+Shift+B` | pick a file and set breakpoints in it |

To print the variables and the surrounding source every time a breakpoint hits,
add this to `~/.jdbrc`:

```
monitor locals
monitor list
```

Leave `monitor where` out on a servlet app — a Jetty stack is 110 frames of
framework and a handful of yours. Type `where` when you actually want it.

### At the jdb prompt

| | |
|---|---|
| `cont` | resume until the next breakpoint |
| `next` | run this line, stay in this method |
| `step` | step **into** the call on this line |
| `step up` | finish this method, back to the caller |
| `dump x` | every field of an object — what you want for anything non-trivial |
| `print x` | one value; also `print x.method()` and `print x.id + 1` |
| `locals` | variables in the current frame |
| `where` | the call stack |
| `up` / `down` | move a frame, then `locals` again |
| `clear` | list breakpoints; `clear <class>:<line>` removes one |
| `quit` | detach |

Stopped *on* a line means it has not run yet, so a variable assigned there is
still empty. `next` once, then `dump` it.

**A breakpoint freezes the whole JVM**, not just the thread that hit it. On a web
app the server stops accepting requests, so the next one appears to hang —
`cont` restarts it.

If a service is running code built from a different worktree than your pane, the
service list says so; otherwise your line numbers point at the wrong lines.

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
