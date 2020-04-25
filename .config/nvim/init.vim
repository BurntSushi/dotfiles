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
