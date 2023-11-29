" Force neovim to emit true colors.
set termguicolors
" Colors a vertical bar at the given column.
if empty($NEOVIM_COLOR_COLUMN)
  set colorcolumn=80
else
  let &colorcolumn = $NEOVIM_COLOR_COLUMN
endif
" Because dark backgrounds suck. Also, using a naturally light colorscheme
" with a dark background ends up looking pretty bad.
set background=light
" Beautiful theme.
colorscheme summerfruit256
