#!/usr/bin/env zsh
set -e

function dprint() {
    echo ${(q)@}
}

function usage() {
    cat <<EOF
usage: $(basename $0) [OPTION]
Option:
  -n, --dry-run  Don't install files, just show what would be done.
EOF
}

function Do() {
    dprint $@ >&2
    $@
}

if [ $# -gt 0 ]; then
    case $1 in
        (-n|--dry-run)
            function Do() {
                dprint $@
            }
            ;;
        (-h|--help)
            usage
            exit 0
            ;;
        (*)
            usage >&2
            exit 1
            ;;
    esac
fi

Install() {
    local dst
    for f; do
        dst=$(dirname $HOME/$f)
        if [ ! -d $dst ]; then
            Do mkdir -p $dst
        fi
        Do ln -sf $PWD/$f $HOME/$f
    done
}

cd $(git rev-parse --show-toplevel)

function {
    local gitconfig=.gitconfig.common
    if (( ! ${${(f)"$(git config --global --path --get-all include.path)"}[(I)$HOME/$gitconfig]} )); then
        Do git config --global --add include.path $HOME/$gitconfig
    fi
    Install $gitconfig
}

Install .ideavimrc
Install .inputrc
Install .tmux.conf
Install .zlogout .zshenv .zshrc
Install bin/*(.)

case $(uname) in
    (Darwin)
        (
            cd macosx
            Install Library/**/*(.)
        )
        ;;
esac
