# avoid `/usr/libexec/path_helper -s` via /etc/profile
unsetopt global_rcs

export LANG='C'
export LC_TIME='C'

if command -v manpath >/dev/null; then
    MANPATH=$(manpath -q)
fi

function {
    local -a dirs bin man p
    dirs=(
        $HOME
        $HOME/.cabal/bin
        /usr/local
        /opt/local
        /sw
        /usr/pkg
        /usr/X11R6
        /usr
    )
    bin=(bin sbin)
    man=(man share/man)

    path=(${^dirs}/${^bin}(N-/) $path)
    typeset -U path

    manpath=(${^dirs}/${^man}(N-/) $manpath)
    typeset -U manpath

    p=(${^dirs}/include(N-/))
    CPATH=${(j/:/)${(u)p}}
    export CPATH
}

case $(uname) in
    (Darwin)
        export JAVA_HOME=$(/usr/libexec/java_home)
        ;;
esac
