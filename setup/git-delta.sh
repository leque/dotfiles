theme=${1:-Dracula}
#theme=${1:-ansi-light}

if command -v delta > /dev/null; then
    git config --global core.pager delta
    git config --global interactive.diffFilter delta
    git config --global delta.color-only true
    git config --global delta.syntax-theme "$theme"
else
    echo "delta(1) not found. do nothing." >&2
    exit 1
fi
