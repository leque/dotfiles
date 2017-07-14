#!/usr/bin/env zsh
set -e
autoload -U colors && colors

function dprint() {
    echo "${fg[blue]}==>${reset_color}" ${(q)@}
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

while [ $# -gt 0 ]; do
    case $1 in
        (-n|--dry-run)
            function Do() {
                dprint $@
            }
            shift
            ;;
        (-f|--force)
            force=1
            shift
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
done

Install() {
    local dstdir src dst
    for f; do
        dstdir=$(dirname $HOME/$f)
        if [ ! -d $dstdir ]; then
            Do mkdir -p $dstdir
        fi
        src=$PWD/$f
        dst=$HOME/$f
        if [ -e $dst -a -z "$force" -a ! \( -L $dst -a $src = $dst:A \) ]; then
            echo "${fg_bold[red]}==> $dst is already exists. do not overwrite.$reset_color"
        else
            Do ln -sf $src $dst
        fi
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
Install .vimrc
Install .bash_profile .bashrc
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
