#!/bin/sh
# Runs once, during `herdr plugin install`, before herdr registers the plugin.
# A non-zero exit aborts the install, which is what we want: a plugin without
# fzf is not worth registering.
#
# Deliberately does NOT put herdr-nav on PATH. herdr builds in a temp directory
# and moves the checkout afterwards, so any link made here would dangle. That
# job belongs to `plugin-linkbin`, which runs from the startup hook and from
# `herdr-nav setup`.
set -eu

cd "$(dirname "$0")"

echo "herdr-nav: installing dependencies"
./herdr-nav install-deps

# How `update` and `uninstall` know this directory is herdr's, not theirs. Keyed
# to the location rather than the environment: someone typing `herdr-nav update`
# at a shell prompt gets none of herdr's plugin variables. Survives the move to
# the final checkout, because the whole directory moves.
: > .herdr-nav-plugin

echo
echo "herdr-nav: installed. Add the keybindings with:"
echo "    herdr plugin action invoke herdr-nav.setup"
