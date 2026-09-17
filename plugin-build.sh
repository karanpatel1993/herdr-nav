#!/bin/sh
# Runs once, during `herdr plugin install`, before herdr registers the plugin.
# A non-zero exit aborts the install, which is the behaviour we want: a plugin
# without fzf is not worth registering.
set -eu

# Build commands get no plugin env, so locate the checkout from this script.
cd "$(dirname "$0")"
ROOT=$(pwd)

echo "herdr-nav: installing dependencies"
./herdr-nav install-deps

# `herdr-nav help`, `setup`, `doctor` and `setkey` are documented as plain
# commands. The checkout is not on PATH, so link the script where the rest of
# the install already puts things.
BIN=${HERDR_NAV_BIN:-$HOME/.local/bin}
mkdir -p "$BIN"
if [ -e "$BIN/herdr-nav" ] && [ ! -L "$BIN/herdr-nav" ]; then
    echo "herdr-nav: $BIN/herdr-nav is a real file, not a link."
    echo "  A standalone install is already there. Remove it first:"
    echo "    herdr-nav uninstall"
    exit 1
fi
ln -sfn "$ROOT/herdr-nav" "$BIN/herdr-nav"
echo "herdr-nav: linked $BIN/herdr-nav -> $ROOT/herdr-nav"

# How `update` and `uninstall` know they must not touch this directory. Keyed to
# the location rather than the environment: someone typing `herdr-nav update` at
# a shell prompt gets none of herdr's plugin variables.
: > "$ROOT/.herdr-nav-plugin"

case ":${PATH:-}:" in
    *":$BIN:"*) ;;
    *) echo "herdr-nav: note -- $BIN is not on your PATH" ;;
esac

echo "herdr-nav: next run 'herdr-nav setup' to add the keybindings"
