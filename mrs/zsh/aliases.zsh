# Aliases — sourced from ~/.zshrc
# Salvaged from the old mrs/bash/bash_aliases (the rest was Avant/Cygwin-era cruft).

# Editor
alias v="nvim"

# Git shortcuts
alias ga="git add"
alias gc="git commit -m"
alias gco="git checkout"
alias gb="git branch"
# Push current branch and set upstream
alias gpu='git symbolic-ref --short -q HEAD | xargs git push -u origin'
