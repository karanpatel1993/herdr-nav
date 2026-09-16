#!/bin/sh
# herdr-nav installer — the tool plus its dependencies.
#   curl -fsSL https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/install.sh | sh
#
# Installs into a directory already on your PATH, else ~/.local/bin.
#   HERDR_NAV_BIN=/somewhere   install elsewhere
#   HERDR_NAV_NO_DEPS=1        skip dependency installation
set -eu

SRC=https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/herdr-nav

fetch() {
    if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
    else echo "herdr-nav: need curl or wget" >&2; exit 1; fi
}

BIN=${HERDR_NAV_BIN:-}
if [ -z "$BIN" ]; then
    for d in "$HOME/.local/bin" "$HOME/bin"; do
        case ":${PATH:-}:" in *":$d:"*) [ -d "$d" ] && { BIN=$d; break; } ;; esac
    done
    [ -n "$BIN" ] || BIN=$HOME/.local/bin
fi
mkdir -p "$BIN"

echo "Installing herdr-nav to $BIN"
fetch "$SRC" "$BIN/herdr-nav.tmp"
head -1 "$BIN/herdr-nav.tmp" | grep -q '^#!' || {
    rm -f "$BIN/herdr-nav.tmp"
    echo "herdr-nav: download failed (not a script)" >&2; exit 1
}
chmod +x "$BIN/herdr-nav.tmp"
mv "$BIN/herdr-nav.tmp" "$BIN/herdr-nav"
echo "  $("$BIN/herdr-nav" version)"

# fzf, fd, bat and ripgrep. Static builds, so this never asks for a password;
# anything already on PATH is left alone.
if [ "${HERDR_NAV_NO_DEPS:-0}" = 0 ]; then
    echo
    echo "Dependencies:"
    "$BIN/herdr-nav" install-deps 2>&1 | sed -n '/^  /p' || true
fi

echo
case ":${PATH:-}:" in
    *":$BIN:"*) ;;
    *)  sh_name=${SHELL:-}; sh_name=${sh_name##*/}
        case "$sh_name" in
            zsh)  rc=~/.zshrc ;; bash) rc=~/.bashrc ;;
            fish) rc=~/.config/fish/config.fish ;; *) rc="your shell rc" ;;
        esac
        echo "Add $BIN to your PATH:"
        echo "  echo 'export PATH=\"$BIN:\$PATH\"' >> $rc && exec \$SHELL"
        echo ;;
esac

# Show what `setup` would add, so it can be reviewed (and changed) first.
"$BIN/herdr-nav" keys 2>/dev/null || {
    echo "Next:"
    echo "  herdr-nav setup     # add the keybindings to herdr and reload"
}
echo "Check setup:   herdr-nav doctor"
