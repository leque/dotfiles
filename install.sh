#!/bin/sh
set -e

dprint() {
    printf '\033[34m==>\033[0m '
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
            if command -v perl >/dev/null; then
                realdst=$(perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$dst")
            elif command -v realpath >/dev/null; then
                realdst=$(realpath "$dst")
            else
                realdst=$(readlink "$dst")
            fi

            if [ -L "$dst" ] && [ "$src" = "$realdst" ]; then
                printf '\033[36m==> %s\033[0m\n' \
                       "already installed: $dst"
            else
                printf '\033[1m\033[31m==> %s\033[0m\n' \
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
