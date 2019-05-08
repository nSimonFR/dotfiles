" Vundle configuration:
set nocompatible							" be iMproved, required
filetype off									" required
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
let g:ycm_confirm_extra_conf = 0
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-sensible'
Plugin 'rizzatti/dash.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
call vundle#end()
filetype plugin indent on

" My configuration

" Functions
function FixTabs()
	if &expandtab
		set noexpandtab
	else
		set expandtab
	endif
	retab!
endfunction

function CenterPane()
	lefta vnew
	wincmd w
	exec 'vertical resize '. string(&columns * 0.75)
endfunction

fun! FixSpaces()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	silent! %s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfun

" Autocmd
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd BufWritePre *.c,*.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call FixSpaces()

if has("autocmd")
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
		\| exe "normal! g'\"" | endif
endif

syntax on
colorscheme molokai
set undodir=~/.config/nvim/undodir/
set undofile
set background=dark
set encoding=utf-8
set t_Co=256
set noswapfile
set list listchars=tab:»·,trail:·
set cc=80
set ts=2
set sw=2
set expandtab
set cindent
set ruler
set relativenumber
set number
set mouse=""
set colorcolumn=80
set noerrorbells
set visualbell
set wildmenu
set wildmode=longest:full,full
set pastetoggle=<F2>
set langmenu=en_US
set clipboard=unnamed

let g:jsx_ext_required = 0
let $LANG = 'en_US'
