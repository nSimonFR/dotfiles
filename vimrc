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
	set undodir=~/.config/undodir/
	set undofile
endif

syntax on
" colorscheme molokai
set background=dark
set encoding=utf-8
set t_Co=256
set noswapfile
set list listchars=tab:»·,trail:·
set cc=80
set ts=2
set sw=2
set sts=2
set expandtab
set autoindent
set smartindent
set cindent
set mouse=""

" Vundle configuration:
set nocompatible              " be iMproved, required
filetype off                  " required
