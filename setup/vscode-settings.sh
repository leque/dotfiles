#!/bin/sh
vscode_home=
vscode_save=vscode
prog="$(basename "$0")"
topdir="$(git rev-parse --show-toplevel)"

cd "$topdir"
mkdir -p "$vscode_save"

usage() {
    cat <<EOF
usage: $prog save
       $prog restore
EOF
}

save_settings() {
    code --list-extensions > "$vscode_save/extensions.txt"
    cp -f "$vscode_home/settings.json" "$vscode_save"
    cp -f "$vscode_home/keybindings.json" "$vscode_save"
}

restore_settings() {
    cat "$vscode_save/extensions.txt" | xargs -n 1 code --install-extension
    cp -f "$vscode_save/settings.json" "$vscode_home"
    cp -f "$vscode_save/keybindings.json" "$vscode_home"
}

# Settings file locations
# https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
# Why doesn't code(1) tell me this?
code_user="Code/User"
vscode_home_win="$HOME/AppData/Roaming/$code_user"
vscode_home_mac="$HOME/Library/Application Support/$code_user"
vscode_home_linux="$HOME/.config/$code_user"

find_home0() {
    for d; do
        if [ -d "$d" ]; then
            vscode_home="$d"
            return
        fi
    done
    {
        cat <<EOF
$prog: cannot find vscode's settings directory. You have never run vscode here yet?
Candidates are:
EOF
        for d; do cat <<EOF; done
  - $d
EOF
    } >&2
    exit 1
}

find_home() {
    find_home0 \
        "$vscode_home_win"	\
        "$vscode_home_mac"	\
        "$vscode_home_linux"	\
        ;
    echo "$prog: vscode_home=$vscode_home" >&2
}

case $1 in
    (save)
        find_home
        save_settings
        ;;
    (restore)
        find_home
        restore_settings
        ;;
    (-h|--help|help)
        usage
        exit 0
        ;;
    (*)
        usage >&2
        exit 1
        ;;
esac
