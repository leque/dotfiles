#!/bin/sh
umask 022

CDPATH=".:$HOME"
FIGNORE=.o:.aux:.out

for pager in lv
do
    if command -v $pager >/dev/null; then
        export PAGER=$pager
        break
    fi
done

export LANG=ja_JP.UTF-8
export EDITOR=vi
export LV="-Ou -s -c"
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
