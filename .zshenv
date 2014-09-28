C_INCLUDE_PATH=/usr/include
LD_LIBRARY_PATH=/usr/lib

for dir in /usr/X11R6 /usr/pkg /sw /opt/local /usr/local "$SCALA_HOME" "$HOME/.cabal" "$HOME"
do
    PATH=$dir/bin:$dir/sbin:$PATH

    if [ -d "$dir/include" ]; then
        C_INCLUDE_PATH="$C_INCLUDE_PATH:$dir/include"
    fi

    if [ -d "$dir/lib" ]; then
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$dir/lib"
    fi

    if [ -d "$dir/man" ]; then
        MANPATH="$MANPATH:$dir/man"
    fi
done

typeset -U path
path=(${^path}(N))

LIBRARY_PATH="$LD_LIBRARY_PATH"
CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"

export C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH
export LIBRARY_PATH
export LD_LIBRARY_PATH

case `uname` in
    Darwin)
        DYLD_FALLBACK_LIBRARY_PATH="$LD_LIBRARY_PATH"
        export DYLD_FALLBACK_LIBRARY_PATH

        export JAVA_HOME=/Library/Java/Home
        ;;
esac

export LANG='C'
export LC_TIME='C'
