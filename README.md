# herdr-nav

Navigate, search and debug code without leaving [herdr](https://herdr.dev).

If you run coding agents in herdr but still switch to an IDE to find a file,
search for a string, or check who calls a method, this closes that gap. It is a
single shell script that wires `fzf`, `ripgrep`, `fd`, `bat` and `jdb` into
herdr popups, scoped automatically to the git worktree you are working in.

It is **not** a language server. Search is text, not semantics — see
[What it can't do](#what-it-cant-do) before you rely on it.

```
prefix+⇧O   go to file            prefix+⇧U   find usages
prefix+⇧C   go to class           prefix+⇧I   find callers of a method
prefix+⇧F   find in files         prefix+⇧M   go to definition
prefix+⇧E   recent files          prefix+⇧B   set breakpoints by browsing
prefix+⇧V   project tree          prefix+⇧S   attach jdb to a service
                                  prefix+⇧A   attach jdb to every service
```

## Install

Needs `fzf`, `fd` (or `fdfind`), `bat` (or `batcat`), `ripgrep`.
Optional: `lf` for the tree, a JDK for the debugger, `jq` for multi-service attach.

```sh
curl -fsSL https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav \
  -o ~/.local/bin/herdr-nav && chmod +x ~/.local/bin/herdr-nav

herdr-nav doctor    # check dependencies and see what it detected
herdr-nav keys      # prints bindings -- paste into ~/.config/herdr/config.toml
herdr config check && herdr server reload-config
```

`herdr-nav keys` reads your existing config **and** herdr's built-in defaults,
then reassigns any binding that would collide, telling you where it moved it.
It never edits your config: it prints, you paste.

## Navigating

Every result list keeps going instead of dead-ending:

```
prefix+⇧I    Callers of: fillDob
             → ProfileConsumer.java:278
Enter        → lands in that file at line 278
Ctrl+R       → pick an identifier → its callers (or usages, if it's a variable)
Enter        → lands there
Ctrl+]       → pick an identifier → its definition
Esc Esc      → walks back up the chain
```

`Enter` descends, `Esc` climbs back. Navigation recurses, so unwinding *is* the
back-stack. Depth is capped at 25.

**In a results list:** `Enter` go there · `Ctrl+P` send `path:line` to your pane ·
`Ctrl+T` set a breakpoint · `Ctrl+V` view · `Alt+W` resize preview · `Esc` back.

**In the line browser:** `Tab` mark several lines · `Enter` breakpoint(s) ·
`Ctrl+R` callers/usages · `Ctrl+]` definition · `Ctrl+P` path to pane.

**The mouse works everywhere** — click to select, double-click to open, scroll the
list and the preview.

### Which key for what

| You want | Key |
|---|---|
| A file you can name | `⇧O`, or `⇧C` if you know the class |
| Any text, anywhere | `⇧F` |
| Who calls this method | `⇧I` — excludes the declaration |
| Where this variable is used | `⇧U` |
| Where this is defined | `⇧M` — declaration plus every override |

## Debugging

`prefix+⇧S` lists live JDWP ports and attaches `jdb` with every source directory
on the sourcepath, so `list` shows real code. `prefix+⇧A` opens one pane per
service — JDWP allows a single debugger per JVM, so a multi-service trace needs
a session each. Panes are labelled by service, and split alternately so they tile.

`prefix+⇧B` browses a file and sets breakpoints on any lines you mark with `Tab`,
sending ready-to-run `stop at` commands to your jdb pane. Commands are joined so
every one but the last executes on arrival — you press the final Enter, and
nothing fires in a pane that isn't a debugger without you seeing it first.

For variables printed automatically on every stop, put this in `~/.jdbrc`:

```
monitor where
monitor locals
```

The port picker flags when a JVM was started from a **different worktree** than
your pane. Line numbers only line up with the code that is actually running, and
this is the failure that otherwise costs you an afternoon.

## Configuration

Optional, at `~/.config/herdr-nav/config` — see [`config.example`](config.example).
The one worth setting is `HERDR_NAV_DEBUG_PORTS`, which names your project's JDWP
ports so the picker shows services instead of bare numbers.

| Variable | Default | |
|---|---|---|
| `HERDR_NAV_OPEN` | `pane` | what `Ctrl+P` does: `pane`, `idea`, `print` |
| `HERDR_NAV_DEBUG_PORTS` | — | `"5005:api 5019:worker"` |
| `HERDR_NAV_MIN_QUERY` | `3` | ignore shorter live-search queries |
| `HERDR_NAV_MAX_HITS` | `20000` | cap on results handed to fzf |

## What it can't do

**No semantics.** Search is regex over text. It cannot tell your `status` from an
unrelated class's `status`. `⇧I` and `⇧M` use the shape of Java declarations to
separate calls from definitions, which is accurate for distinctive names and
noisy for short ones. Overloads are indistinguishable, interface dispatch is
invisible, and reflection or DI-wired calls never appear. **Zero results means
"not found textually", never "this is dead code".**

**Lombok, generated sources and dependency jars have no source to find** — a
`getFoo()` on an `@Data` class or anything inside a jar returns nothing.

**Local variables need scoping.** A local's real usages are within its file:

```sh
herdr-nav usages uc path/to/TheFile.java
```

Repo-wide, a two-letter name returns hundreds of unrelated hits.

**No ⌘-click.** Terminal mouse reports carry no Command modifier — they cannot
distinguish ⌘-click from a plain click. This is a protocol limit, not a herdr one.

## Two things that will bite you

**Bindings need an absolute path.** The herdr server runs with a bare `PATH` — no
`~/.local/bin`, no version-manager bins. `herdr config check` happily reports `ok`
for a bare command name, which then fails silently at keypress time.
`herdr-nav keys` emits absolute paths for exactly this reason.

**Under `herdr --remote`, the client uses your *local* keybindings.** Bindings in
the remote config are only reachable *after* the prefix, because the server
resolves post-prefix keys. `prefix+X` works; a bare `ctrl+alt+X` chord does not,
unless you attach with `--remote-keybindings server`.

Bindings use **shift**, not option/alt, deliberately: alt arrives as `ESC`+`<key>`,
two bytes that can land split over an SSH attach — and then the first press is
swallowed. Shift is carried in the character itself.

## License

MIT
