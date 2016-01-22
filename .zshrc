PS1='%~%# '
RPS1='%{[31m%}[%n@%m]%{[m%}'

cdpath=(. $HOME)
fpath=($fpath $HOME/.zfunctions)
fignore=(.o .aux .out)

for pager in lv
do
    if command -v $pager >/dev/null; then
        export PAGER=$pager
        break
    fi
done

export LANG=ja_JP.UTF-8
export EDITOR=vi
export LV="-Ou -s -c"
export RLWRAP_HOME=$HOME/.rlwrap

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias ls='ls -F'

dup() {
    for f
    do
        cp -pi $f $f.orig
    done
}

# History
HISTFILE=$HOME/.zhistory
HISTSIZE=100000
SAVEHIST=100000

# Global aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g //="| autopager $PAGER"

# Options
setopt always_last_prompt auto_cd auto_list auto_menu auto_param_keys
setopt auto_remove_slash complete_in_word correct extended_glob
setopt hist_ignore_all_dups hist_ignore_space hist_no_store hist_reduce_blanks
setopt list_ambiguous no_beep no_list_beep no_clobber prompt_subst
setopt share_history

# Completions
## for ssh
if test -f ~/.ssh/known_hosts; then
    _cache_hosts=($(awk < ~/.ssh/known_hosts '
  { if (match($0, /^[A-Za-z0-9.:%-]+/)) {
    print(substr($0, RSTART, RLENGTH))
  } }'))
fi

autoload -U compinit
compinit -u

zstyle ':completion:*' use-cache true
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

compdef _man jman
compdef _tex platex
compdef -d javac java

# key bindings
bindkey -v

bindkey -a '/' vi-history-search-forward
bindkey -a '?' vi-history-search-backward

bindkey -a 'q' push-line

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N  up-line-or-beginning-search
zle -N  down-line-or-beginning-search
bindkey '' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '[A' up-line-or-beginning-search
bindkey '[B' down-line-or-beginning-search
bindkey -a 'k' up-line-or-beginning-search
bindkey -a 'j' down-line-or-beginning-search
bindkey -a '/' vi-history-search-forward
bindkey -a '?' vi-history-search-backward
bindkey -a '' vi-up-line-or-history
bindkey -a '^N' vi-down-line-or-history
bindkey -a '[A' up-line-or-beginning-search
bindkey -a '[B' down-line-or-beginning-search

# Local configurations
if [ -d ~/.zsh ]; then
    for rc in $(find ~/.zsh -type f -user $USER -not -perm go+w -prune)
    do
        source $rc
    done
fi
