theme=${1:-Dracula}

if command -v delta > /dev/null; then
    git config --global core.pager "delta --color-only --theme '$theme'"
    git config --global interactive.diffFilter "delta --color-only --theme '$theme'"
else
    echo "delta(1) not found. do nothing." >&2
    exit 1
fi
