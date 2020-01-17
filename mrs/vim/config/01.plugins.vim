set runtimepath+=/Users/mroses43/.cache/dein/repos/github.com/Shougo/dein.vim
"
" Setup dein  ---------------------------------------------------------------{{{
if dein#load_state('~/.cache/dein')
    call dein#begin('~/.cache/dein')

    call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
    call dein#add('Shougo/deoplete.nvim')
    if !has('nvim')
        call dein#add('roxma/nvim-yarp')
        call dein#add('roxma/vim-hug-neovim-rpc')
    endif

    " Add or remove plugins here
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('sheerun/vim-polyglot')
    call dein#add('Shougo/deol.nvim')
    call dein#add('Shougo/deoplete.nvim')
    call dein#add('zchee/deoplete-zsh')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('Shougo/neco-vim')
    call dein#add('icymind/NeoSolarized')
    call dein#add('tmhedberg/SimpylFold')
    call dein#add('Konfekt/FastFold')
    call dein#add('w0rp/ale')
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('alaric/neovim-visor')
    call dein#add('christoomey/vim-tmux-navigator')
    call dein#add('autozimu/LanguageClient-neovim', {
                \ 'rev': 'next',
                \ 'build': 'bash install.sh',
                \ })
    call dein#add('tpope/vim-surround')
    call dein#add('tpope/vim-commentary')
    call dein#add('Vigemus/iron.nvim') " ipython repl
    call dein#add('mhinz/vim-sayonara')
    call dein#add('vimwiki/vimwiki')

    call dein#end()"
    call dein#save_state()
endif

" Required:
    

filetype plugin indent on
syntax enable

if dein#check_install()
	call dein#install()
endif
