#!/bin/sh
set -e

__reset=$(tput sgr0)
__bold=$(tput bold)
__redfg=$(tput setaf 1)
__bluefg=$(tput setaf 4)
__cyanfg=$(tput setaf 6)

dprint() {
    printf "${__bluefg}==>${__reset} "
    echo "$@"
}

usage() {
    cat <<EOF
usage: $(basename "$0") [OPTION]
Option:
  -f, --force    Force overwrite existing files.
  -h, --help     Show this message.
  -n, --dry-run  Don't install files, just show what would be done.
EOF
}

Do() {
    dprint "$@" >&2
    "$@"
}

while [ $# -gt 0 ]; do
    case "$1" in
        (-n|--dry-run)
            Do() {
                dprint "$@"
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

if command -v perl >/dev/null; then
    ReadLink() { perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$1"; }
elif command -v realpath >/dev/null; then
    ReadLink() { realpath "$1"; }
else
    ReadLink() { readlink "$1"; }
fi

Install() {
    for f; do
        src="$PWD/$f"
        dst="$HOME/$f"
        dstdir=$(dirname "$dst")

        if [ ! -d "$dstdir" ]; then
            Do mkdir -p "$dstdir"
        fi

        if [ "$force" ] || [ ! -e "$dst" ]; then
            Do ln -sf "$src" "$dst"
        else
            realdst=$(ReadLink "$dst")

            if [ -L "$dst" ] && [ "$src" = "$realdst" ]; then
                printf "${__cyanfg}==> %s${__reset}\n" \
                       "already installed: $dst"
            else
                printf "${__bold}${__redfg}==> %s${__reset}\n" \
                       "already exists: $dst"
            fi
        fi
    done
}

cd "$(git rev-parse --show-toplevel)"

if ! git config --global --path --get-all include.path \
        | grep "^$HOME/.gitconfig.common$" >/dev/null
then
    Do git config --global --add include.path "$HOME/.gitconfig.common"
fi
Install .gitconfig.common

Install .ideavimrc
Install .inputrc
Install .tmux.conf
Install .vimrc
Install .config/env.sh
Install .config/tmux/*
Install .config/utop/*
Install .bash_profile .bashrc
Install .zlogout .zshenv .zshrc
Install bin/*

case $(uname) in
    (Darwin)
        (
            cd macosx
            find Library -type f | while read -r f; do
                Install "$f";
            done
        )
        ;;
esac
