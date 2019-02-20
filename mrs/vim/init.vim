for f in split(glob('~/dotfiles/mrs/vim/config/*.vim'), '\n')
	exe 'source' f
endfor
