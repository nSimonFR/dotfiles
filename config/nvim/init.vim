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

function FixSpaces()
	:%s/\s\+$//e
endfunction

function Cursor()
	undo
	redo
endfunction

" Autocmd
autocmd VimEnter * call Cursor()
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" set
if has("persistent_undo")
	set undodir=~/.config/nvim/undodir/
	set undofile
endif

syntax on
colorscheme molokai
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
set number
set mouse=""
set colorcolumn=80
set visualbell

set pastetoggle=<F2>
