CDPATH=".:~"

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias ls='ls -F'

for f in ~/share/bash-completion/bash_completion; do
    if [ -f "$f" ]; then
        . "$f"
        break
    fi
done
