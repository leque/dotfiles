#!/bin/sh
tmp=$(mktemp -t "$(basename "$0")")
ent=tmux-256color

atexit() {
    rm -f "$tmp"
}

trap atexit EXIT
trap 'st=$?; trap - EXIT; atexit; exit $st' INT TERM

/usr/local/opt/ncurses/bin/infocmp "$ent" > "$tmp" &&
    tic -xe "$ent" "$tmp"
