" Vundle configuration:
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
let g:ycm_confirm_extra_conf = 0
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()
filetype plugin indent on

" My configuration :

function FixTabs()
	if &expandtab
		set noexpandtab
	else
		set expandtab
	endif
	retab!
endfunction

function FixSpaces()
	:%s/\s\+$//e
endfunction

function Cursor()
	undo
	redo
endfunction
autocmd! VimEnter * call Cursor()

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
set ts=4
set sw=4
set noexpandtab
set mouse=""

set pastetoggle=<F2>
