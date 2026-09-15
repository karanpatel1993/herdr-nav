#!/bin/sh
# herdr-nav installer.
#   curl -fsSL https://raw.githubusercontent.com/karanpatel1993/herdr-nav/main/install.sh | sh
# Override the destination with HERDR_NAV_BIN=/somewhere/bin
set -eu

REPO=karanpatel1993/herdr-nav
SRC=https://raw.githubusercontent.com/$REPO/main/herdr-nav

# Prefer a directory that is already on PATH, so nothing has to be added.
pick_dir() {
    [ -n "${HERDR_NAV_BIN:-}" ] && { printf '%s' "$HERDR_NAV_BIN"; return; }
    for d in "$HOME/.local/bin" "$HOME/bin"; do
        case ":$PATH:" in *":$d:"*) [ -d "$d" ] && { printf '%s' "$d"; return; } ;; esac
    done
    printf '%s' "$HOME/.local/bin"
}

BIN=$(pick_dir)
mkdir -p "$BIN" || { echo "herdr-nav: cannot create $BIN" >&2; exit 1; }

echo "Installing herdr-nav to $BIN"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SRC" -o "$BIN/herdr-nav.tmp"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$BIN/herdr-nav.tmp" "$SRC"
else
    echo "herdr-nav: need curl or wget" >&2; exit 1
fi

# Only replace an existing install once the download is known good.
head -1 "$BIN/herdr-nav.tmp" | grep -q '^#!' || {
    rm -f "$BIN/herdr-nav.tmp"
    echo "herdr-nav: download looks wrong (not a script); aborting" >&2; exit 1
}
chmod +x "$BIN/herdr-nav.tmp"
mv "$BIN/herdr-nav.tmp" "$BIN/herdr-nav"

VER=$("$BIN/herdr-nav" version 2>/dev/null || echo "herdr-nav")
echo "Installed $VER"
echo

case ":$PATH:" in
    *":$BIN:"*) ;;
    *)
        case "${SHELL##*/}" in zsh) RC=~/.zshrc ;; bash) RC=~/.bashrc ;; fish) RC=~/.config/fish/config.fish ;; *) RC="your shell rc" ;; esac
        echo "$BIN is not on your PATH. Add it:"
        echo "  echo 'export PATH=\"$BIN:\$PATH\"' >> $RC && exec \$SHELL"
        echo
        ;;
esac

echo "Next:"
echo "  herdr-nav doctor    # check dependencies"
echo "  herdr-nav keys      # bindings to paste into ~/.config/herdr/config.toml"
