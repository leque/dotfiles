# avoid `/usr/libexec/path_helper -s` via /etc/profile
unsetopt global_rcs

export LANG='C'
export LC_TIME='C'

if command -v manpath >/dev/null; then
    MANPATH=$(manpath -q)
fi

path=
if [ -x /usr/libexec/path_helper ]; then
    eval $(/usr/libexec/path_helper -s)
fi

typeset -xT CPATH cpath

function {
    local -a dirs bin man
    dirs=(
        $HOME
        $HOME/.cabal
        $HOME/.dotnet/tools
        $HOME/.local
        /usr/local
        /opt/local
        /sw
        /usr/pkg
        /usr/X11R6
        /usr
        ""
    )
    bin=(sbin bin)
    man=(man share/man)

    typeset -xU path manpath cpath
    path=(${^dirs}/${^bin}(N-/) $path)
    manpath=(${^dirs}/${^man}(N-/) $manpath)
    cpath=(${^dirs}/include(N-/))
}

case $(uname) in
    (Darwin)
        export JAVA_HOME=$(/usr/libexec/java_home)
        export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
        ;;
esac
