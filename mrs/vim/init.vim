if &compatible
  set nocompatible
endif
set runtimepath+=.config/nvim/dein/repos/github.com/Shougo/dein.vim/

if dein#load_state(expand('~/.config/nvim/dein'))
  call dein#begin(expand('~/.config/nvim/dein'))

  call dein#add('.config/nvim/dein/repos/github.com/Shougo/dein.vim/')
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif
  call dein#add('sheerun/vim-polyglot')
  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/denite.nvim')
  call dein#add('Konfekt/FastFold')
  call dein#add('mhinz/vim-sayonara')
  call dein#add('ryanoasis/vim-devicons')
  call dein#add('tpope/vim-commentary')
  call dein#add('kassio/neoterm')
  call dein#add('vim-scripts/neovim-remote')
  call dein#add('morhetz/gruvbox')
  call dein#add('ervandew/supertab')
  call dein#add('tpope/vim-surround')
  call dein#add('hkupty/iron.nvim')
  call dein#add('zchee/deoplete-jedi')
  call dein#add('neomake/neomake')
  call dein#add('vim-airline/vim-airline')


  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

let g:python_host_prog  = '/home/mrs/.pyenv/versions/py2/bin/python'
let g:python3_host_prog = '/home/mrs/.pyenv/versions/py3/bin/python'
map <space> <leader>
map <space><space> <leader><leader>

let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
colorscheme gruvbox
set background=dark

set clipboard+=unnamedplus
set number
set noswapfile

" use deoplete for python autocompletion
let g:deoplete#enable_at_startup = 1
let g:jedi#completions_enabled = 0
let g:jedi#documentation_command = "<leader>k"
let g:jedi#rename_command = "<leader>e"

nmap 0 ^

" edit and source config file
nmap <leader>vr :sp $MYVIMRC<cr>
nmap <leader>so :source $MYVIMRC<cr>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

imap jk <esc>
imap kj <esc>

" resize windows and allow faster zooming
autocmd VimResized * :wincmd =
nnoremap <leader>- :wincmd _<cr>:wincmd \|
nnoremap <leader>= :wincmd =<cr>

" highlighted text indents all at once
vmap < <gv
vmap > >gv

" Terminal
tmap <esc> <c-\><c-n><esc><cr>
augroup terminal_commands
	au!
	au BufEnter * if &buftype == "terminal" | startinsert | endif
augroup END

let g:neoterm_size = 15
nnoremap <leader>t :Ttoggle<CR>

" ipython terminal
noremap <leader>r :IronRepl<CR>

let g:iron_map_defaults=0
augroup ironmapping
	autocmd!
	autocmd Filetype python nmap <buffer> <leader>s <Plug>(iron-send-motion)
	autocmd Filetype python vmap <buffer> <leader>s <Plug>(iron-send-motion)
	autocmd Filetype python nmap <buffer> <leader>p <Plug>(iron-repeat-cmd)
augroup END


	"
" sayonara setup
cnoreabbrev <expr> x getcmdtype() == ":" && getcmdline() == 'x' ? 'Sayonara' : 'x'

" buffer management
nnoremap <leader>l :ls<CR>
nnoremap <leader>b :bp<CR>
nnoremap <leader>f :bn<CR>
nnoremap <leader>1 :1b<CR>
nnoremap <leader>2 :2b<CR>
nnoremap <leader>3 :3b<CR>
nnoremap <leader>4 :4b<CR>
nnoremap <leader>5 :5b<CR>

let g:neomake_python_enabled_makers = ['flake8']
autocmd! BufWritePost * Neomake

nnoremap <C-p> :<C-u>Denite file_rec<CR>

