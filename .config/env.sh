#!/bin/sh
umask 022

CDPATH=".:$HOME"
FIGNORE=.o:.aux:.out

for pager in less
do
    if command -v $pager >/dev/null; then
        export PAGER=$pager
        break
    fi
done

export LANG=ja_JP.UTF-8
export EDITOR=vi
export LV="-Ou -s -c"
export LESS="-iMR"
export RLWRAP_HOME=$HOME/.config/rlwrap

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias ls='ls -F'

for op in open xdg-open; do
    if command -v $op >/dev/null; then
        alias o=$op
    fi
done

if command -v start >/dev/null && command -v cygpath >/dev/null; then
    o() {
        start "$(cygpath -w "$1")"
    }
fi

if command -v cmd.exe >/dev/null && command -v wslpath >/dev/null; then
    o() {
        cmd.exe /c start "" "$(wslpath -w "$1")"
    }
fi

# for WSL
if command -v tasklist.exe >/dev/null && [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    if tasklist.exe | grep -q '^vcxsrv.exe '; then
        export DISPLAY=localhost:0.0
    else
        echo "vcxsrv.exe is not running. check output of tasklist.exe"
    fi
fi
