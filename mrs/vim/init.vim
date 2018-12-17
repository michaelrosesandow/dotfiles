let g:mapleader="\<Space>"
let g:maplocalleader=';' 

" Reserve these keywords for plugin use
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
nnoremap ; <Nop>
xnoremap ; <Nop>

" Setup dein  ---------------------------------------------------------------{{{
if (!isdirectory(expand("$HOME/.config/nvim/repos/github.com/Shougo/dein.vim")))
	call system(expand("mkdir -p $HOME/.config/nvim/repos/github.com"))
	call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.config/nvim/repos/github.com/Shougo/dein.vim"))
endif

set runtimepath+=~/.config/nvim/repos/github.com/Shougo/dein.vim/
call dein#begin(expand('~/.config/nvim'))
" package manager
call dein#add('Shougo/dein.vim')

" show changes in margin
call dein#add('airblade/vim-gitgutter')

" needed for linting
call dein#add('w0rp/ale')

" formatting / editing
call dein#add('sbdchd/neoformat')
call dein#add('Konfekt/FastFold')
call dein#add('tmhedberg/SimpylFold', {'on_ft': 'python'})
call dein#add('tpope/vim-commentary')
call dein#add('tpope/vim-surround')
call dein#add('kana/vim-niceblock') " vipI# will comment out a block of code
call dein#add('easymotion/vim-easymotion') " lets you more easily jump around text
call dein#add('hkupty/iron.nvim') " ipython repl
call dein#add('Vimjas/vim-python-pep8-indent')
call dein#add('vim-python/python-syntax', {'on_ft': 'python'})
call dein#add('vim-scripts/python_match.vim', {'on_ft': 'python'})
call dein#add('kana/vim-textobj-user', {'on_ft': 'python'})
call dein#add('bps/vim-textobj-python', {'on_ft': 'python'})

" sql
call dein#add('lifepillar/pgsql.vim')

" autcompletion
call dein#add('Shougo/deoplete.nvim')
call dein#add('zchee/deoplete-jedi', {'on_ft': 'python'})
call dein#add('Shougo/context_filetype.vim')

" terminal
call dein#add('Shougo/deol.nvim')
call dein#add('zchee/deoplete-zsh')
"
" file finders and git stuff
call dein#add('Shougo/denite.nvim')
call dein#add('chemzqm/vim-easygit')
call dein#add('chemzqm/denite-git')
call dein#add('Shougo/neoinclude.vim')
call dein#add('chemzqm/unite-location') " make sure this is actually useful
call dein#add('rafi/vim-denite-z') "remembers frequent dirs and lets you jump to them

" kill buffers
call dein#add('mhinz/vim-sayonara')

" run sql queries
call dein#add('vim-scripts/dbext.vim')

" let's try nerdtree
call dein#add('scrooloose/nerdtree')
call dein#add('Xuyuanp/nerdtree-git-plugin')

call dein#add('morhetz/gruvbox')

if dein#check_install()
	call dein#install()
	let pluginsExist=1
endif

call dein#end()

filetype plugin indent on

" System Settings  ----------------------------------------------------------{{{
let g:python_host_prog = '/Users/mroses43/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '/Users/mroses43/.pyenv/versions/py3/bin/python'
"
" Neovim Settings
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
colorscheme gruvbox
set background=dark

set clipboard+=unnamedplus
set number
" 0 jumps to first text in line rather than begin of line
nmap 0 ^

" SQL
" highlight all sql
let g:sql_type_default = 'pgsql'
" Adhoc profile for dbext
let g:dbext_default_profile_adhoc='type=pgsql:host=us-adhoc01.int.avant.com:user=mroses43:dbname=deubc3pju2ki49'
let g:dbext_default_profile='adhoc'

" edit vimrc
nmap <leader>vr :sp $MYVIMRC<cr>

" source vimrc
nmap <leader>so :source $MYVIMRC<cr>
"
" Move up and down by visible lines if current line is wrapped
nmap j gj
nmap k gk

" Terminal
nmap <leader>t :DeolEdit
" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" easy escape
imap jk <esc>
imap kj <esc>
" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =
" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

let g:SimplyFold_docstring_preview=1
"
" Python settings
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
" Python jump to functions and classes
" next function
nmap nf ]pf
" prior function
nmap pf [pf
" next class
nmap nc ]pc
" prior class
nmap pc [pc

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=120 |
    \ set expandtab |
    \ set autoindent |
    \ set smartindent |
    \ set fileformat=unix

" launch repl
noremap <leader>r :IronRepl<CR>
" deactivate default mappings

tmap <esc> <c-\><c-n><esc><cr>
let g:iron_map_defaults=0
augroup ironmapping
    autocmd!
    autocmd Filetype python nmap <buffer> <Leader>s <Plug>(iron-send-motion)
    autocmd Filetype python vmap <buffer> <Leader>s <Plug>(iron-send-motion)
    autocmd Filetype python nmap <buffer> <Leader>p <Plug>(iron-repeat-cmd)
augroup END
"
" indent blocks
vmap < <gv
vmap > >gv
nnoremap <Leader>b :bp<CR>
"
" AUTO COMPLETION
" deoplete settings
let g:jedi#completions_enabled=0
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_refresh_always = 0
let g:deoplete#max_abbr_width = 35
let g:deoplete#max_menu_width = 20
let g:deoplete#skip_chars = ['(', ')', '<', '>']
let g:deoplete#tag#cache_limit_size = 800000
let g:deoplete#file#enable_buffer_path = 1

let g:deoplete#sources#jedi#statement_length = 1
let g:deoplete#sources#jedi#show_docstring = 1
let g:deoplete#sources#jedi#short_types = 1
let g:jedi#completions_enabled = 0
let g:jedi#rename_command = "<leader>e"
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#auto_completion_start_length = 2
"
" When pressing <leader>cd switch to the directory of the open buffer
map <Leader>cd :lcd %:p:h<CR>:pwd<CR>

" Denite mappings

if dein#tap('denite.nvim')
	nnoremap <silent><LocalLeader>r :<C-u>Denite -resume<CR>
	nnoremap <silent><LocalLeader>f :<C-u>Denite file_rec<CR>
	nnoremap <silent><LocalLeader>b :<C-u>Denite buffer file_old -default-action=switch<CR>
	nnoremap <silent><LocalLeader>d :<C-u>Denite directory_rec -default-action=cd<CR>
	nnoremap <silent><LocalLeader>l :<C-u>Denite location_list -buffer-name=list<CR>
	nnoremap <silent><LocalLeader>q :<C-u>Denite quickfix -buffer-name=list<CR>
	nnoremap <silent><LocalLeader>g :<C-u>Denite grep<CR>
	nnoremap <silent><LocalLeader>z :<C-u>Denite z<CR>
	nnoremap <silent><LocalLeader>v :<C-u>Denite file_rec -default-action=vsplit<CR>
	nnoremap <silent><LocalLeader>h :<C-u>Denite file_rec -default-action=split<CR>

	" chemzqm/denite-git
	nnoremap <silent> <Leader>gl :<C-u>Denite gitlog<CR>
	nnoremap <silent> <Leader>gs :<C-u>Denite gitstatus<CR>

	" Open Denite with word under cursor or selection
	nnoremap <silent> <Leader>gf :DeniteCursorWord file_rec<CR>
	nnoremap <silent> <Leader>gg :DeniteCursorWord grep<CR>
endif

" more denite mappings
" KEY MAPPINGS
let insert_mode_mappings = [
	\  ['jj', '<denite:enter_mode:normal>', 'noremap'],
	\  ['<Esc>', '<denite:enter_mode:normal>', 'noremap'],
	\ ]

let normal_mode_mappings = [
	\   ["'", '<denite:toggle_select_down>', 'noremap'],
	\   ['<C-n>', '<denite:jump_to_next_source>', 'noremap'],
	\   ['<C-p>', '<denite:jump_to_previous_source>', 'noremap'],
	\   ['gg', '<denite:move_to_first_line>', 'noremap'],
	\   ['vs', '<denite:do_action:vsplit>', 'noremap'],
	\   ['ss', '<denite:do_action:split>', 'noremap'],
	\   ['sc', '<denite:quit>', 'noremap'],
	\   ['a', '<denite:do_action:add>', 'noremap'],
	\   ['d', '<denite:do_action:delete>', 'noremap'], 
	\   ['r', '<denite:do_action:reset>', 'noremap'],
	\ ]
" NOTE: delete is actually diff
for m in insert_mode_mappings
	call denite#custom#map('insert', m[0], m[1], m[2])
endfor
for m in normal_mode_mappings
	call denite#custom#map('normal', m[0], m[1], m[2])
endfor

if dein#tap('vim-gitgutter')
	nmap <Leader>hj <Plug>GitGutterNextHunk
	nmap <Leader>hk <Plug>GitGutterPrevHunk
	nmap <Leader>hs <Plug>GitGutterStageHunk
	nmap <Leader>hr <Plug>GitGutterUndoHunk
	nmap <Leader>hp <Plug>GitGutterPreviewHunk
endif

if dein#tap('vim-commentary')
	xmap <Leader>v  <Plug>Commentary
	nmap <Leader>v  <Plug>CommentaryLine
	xmap gc  <Plug>Commentary
	nmap gc  <Plug>Commentary
	omap gc  <Plug>Commentary
	nmap gcc <Plug>CommentaryLine
	nmap cgc <Plug>ChangeCommentary
	nmap gcu <Plug>Commentary<Plug>Commentary
endif
