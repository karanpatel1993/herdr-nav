# herdr-nav

Find files, search code and debug Java inside [herdr](https://herdr.dev).

A single shell script wiring `fzf`, `ripgrep` and `jdb` into herdr popups,
scoped to the git worktree of the pane you are in.

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
curl -fsSLO https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav
chmod +x herdr-nav
./herdr-nav install

herdr-nav doctor    # what's missing and how to get it
herdr-nav keys      # prints bindings — paste into ~/.config/herdr/config.toml
herdr config check && herdr server reload-config
```

### Dependencies

`fzf`, `fd`, `bat`, `ripgrep`. `doctor` lists any that are missing and prints the
command to install them.

If you cannot install packages on that machine:

```sh
herdr-nav install-deps    # downloads them into ~/.local/bin
```

## Navigating

Every search gives you a list. `Enter` on a result opens that file at that line —
where you can search again. That is how you follow a call chain without starting
over.

Tracing who calls `fillDob`:

```
prefix+⇧I     type "fillDob"        → every call site
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

`prefix+⇧S` attaches `jdb` to a live service with your source tree on the
sourcepath. `prefix+⇧A` opens a pane per service. `prefix+⇧B` turns lines you
mark into `stop at` commands.

For variables printed on every stop, put this in `~/.jdbrc`:

```
monitor where
monitor locals
```

The port picker warns when a service was built from a different worktree than
your pane.

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

Search is text, not semantics. It cannot tell your `status` from another class's
`status`; overloads look alike; interface dispatch, reflection, Lombok and jar
code are invisible. **Zero results means "not found textually", not "dead code".**

Scope a local variable to its file — repo-wide, a short name is mostly noise:

```sh
herdr-nav usages uc path/to/TheFile.java
```

Linux and macOS; Windows needs WSL. [NOTES.md](NOTES.md) has the details.

MIT
