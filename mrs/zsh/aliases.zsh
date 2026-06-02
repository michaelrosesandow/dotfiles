# Aliases — sourced from ~/.zshrc
# Salvaged from the old mrs/bash/bash_aliases (the rest was Avant/Cygwin-era cruft).

# Editor
alias v="nvim"

# Obsidian quick-capture from anywhere: `oc some thought` (or bare `oc` to be
# prompted) appends a bullet under today's daily-note "## Scratch Pad" -- the
# same target as the <leader>oc keymap in nvim, reusing that exact Lua logic.
# Runs a bare `-u NONE` nvim (~50ms, no config/plugins) and passes the text via
# an env var so quotes/brackets can't break or inject.
oc() {
	local text="$*"
	[[ -z "$text" ]] && { printf "Capture: " >&2; read -r text; }
	[[ -z "$text" ]] && return 1
	OBS_CAPTURE="$text" nvim --headless -u NONE \
		-c "lua dofile(vim.fn.expand('~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua')).append(vim.env.OBS_CAPTURE)" \
		-c "qa" >/dev/null 2>&1 && printf "✓ captured\n" >&2
}

# Git shortcuts
alias ga="git add"
alias gc="git commit -m"
alias gco="git checkout"
alias gb="git branch"
# Push current branch and set upstream
alias gpu='git symbolic-ref --short -q HEAD | xargs git push -u origin'
