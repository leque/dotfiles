syntax on

set clipboard=unnamed

set shiftwidth=4
set expandtab

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,euc-jp,sjis,cp932
set ambiwidth=double

set smartcase
set hlsearch
set backspace=indent,eol,start
set list
set listchars=tab:>\ ,trail:_,precedes:<,extends:\
set laststatus=2
set showcmd
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P

highlight SpecialKey ctermfg=cyan

if has('vim_starting')
    " blinking line cursor in insert mode
    let &t_SI .= "\e[5 q"
    " blinking block cursor in command mode
    let &t_EI .= "\e[0 q"
    " bliking underline in replace mode
    let &t_SR .= "\e[3 q"
endif
