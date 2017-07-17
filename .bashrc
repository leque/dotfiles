. ~/.config/env.sh

for f in ~/share/bash-completion/bash_completion; do
    if [ -f "$f" ]; then
        . "$f"
        break
    fi
done
