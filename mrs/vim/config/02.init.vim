" misc startup settings for vim
"
"
"
" python packages
let g:python_host_prog = '/Users/mroses43/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '/Users/mroses43/.pyenv/versions/py3/bin/python'

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Enable syntax highlighting
syntax on

set backspace=indent,eol,start

" enable line numbers
set nu

" enable line/column info
set ruler
set cursorline

set scrolloff=10

" Autoindentation
set ai
filetype indent plugin on

" Copy using system clipboard
set clipboard+=unnamedplus

" Tabs are 4 spaces
set tabstop=4
set shiftwidth=4
set sta
set et
set sts=4

" markdown file recognition
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" use ripgreg instead of grep
set grepprg=rg\ --vimgrep


" Set colors in terminal
" Solarized, dark, with true color support
"
set termguicolors
set background=dark
colorscheme NeoSolarized

let g:ale_completion_enabled = 0
let g:ale_linters_explicit = 1

" terminal settings
autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

let g:mapleader="\<Space>"
