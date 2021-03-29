# avoid `/usr/libexec/path_helper -s` via /etc/profile
unsetopt global_rcs

export LANG='C'
export LC_TIME='C'

if command -v manpath >/dev/null; then
    MANPATH=$(manpath -q)
fi

my_add_to_list() {
    local target v
    target=$1
    shift
    for v; do
        if ((! ${${(P)target}[(Ie)$v]})); then
            set -A $target $v ${(P)target}
        fi
    done
}

typeset -xT CPATH cpath

function {
    local -a dirs bin man
    dirs=(
        ""
        /usr
        /usr/X11R6
        /usr/pkg
        /sw
        /opt/local
        /usr/local
        $HOME/.cabal
        $HOME
    )
    bin=(bin sbin)
    man=(man share/man)

    my_add_to_list path ${^dirs}/${^bin}(N-/)
    my_add_to_list manpath ${^dirs}/${^man}(N-/)
    my_add_to_list cpath ${^dirs}/include(N-/)
}

unfunction my_add_to_list

case $(uname) in
    (Darwin)
        export JAVA_HOME=$(/usr/libexec/java_home)
        ;;
esac
