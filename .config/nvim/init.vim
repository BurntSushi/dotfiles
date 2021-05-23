" I'm trying out neovide (so bootiful), and this needs to be set first:
" https://github.com/Kethku/neovide/tree/0b976c3d28bbd24e6c83a2efc077aa96dde1e9eb#troubleshooting
set guifont=Hack\ Nerd\ Font:h16

" Install plugins first. We may configure plugins for specific languages later.
runtime! include/plugins.vim
" This is next because it sets language specific variables.
runtime! include/lang.vim

runtime! include/autos.vim
runtime! include/comment.vim
runtime! include/keybinds.vim
runtime! include/options.vim
runtime! include/style.vim
runtime! include/windows.vim
