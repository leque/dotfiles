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
  -v, --verbose  Show what is going to be done
EOF
}

function Do() {
    $@
}

if [ $# -gt 0 ]; then
    case $1 in
        (-n|--dry-run)
            function Do() {
                dprint $@
            }
            ;;
        (-v|--verbose)
            function Do() {
                dprint $@ >&2
                $@
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

Install .gitconfig
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
