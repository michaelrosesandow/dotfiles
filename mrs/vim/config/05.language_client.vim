" language_client.vim contains vim settings specific to the language
" client plugin

" language server commands
let g:LanguageClient_serverCommands = {
            \ 'python': ['/Users/mroses43/.pyenv/versions/py3/bin/pyls']
            \ }
let g:LanguageClient_autoStart = 1

set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()
