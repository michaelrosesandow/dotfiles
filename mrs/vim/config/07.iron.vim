" launch repl
noremap <leader>r :IronRepl<CR>

let g:iron_map_defaults=0
augroup ironmapping
    autocmd!
    autocmd Filetype python nmap <buffer> <Leader>s <Plug>(iron-send-motion)
    autocmd Filetype python vmap <buffer> <Leader>s <Plug>(iron-send-motion)
    autocmd Filetype python nmap <buffer> <Leader>p <Plug>(iron-repeat-cmd)
augroup END

lua require("iron").core.set_config({preferred = {python = "ipython"}, repl_open_cmd = "rightbelow 20 split"})

