au FileType go
  \ let b:Comment="//"
  \ | let b:EndComment=""
  \ | let g:gofmt_command="goimports"
  \ | source ~/.vim/eightspaces.vim
  \ | setlocal noexpandtab
  \ | setlocal colorcolumn=100

au FileType rust
  \ let b:Comment="//"
  \ | let b:EndComment=""
  \ | let b:syntastic_mode="passive"
  \ | source ~/.vim/fourspaces.vim
  \ | syntax sync fromstart
  \ | noremap <buffer> gr :ALEFindReferences<CR>h
  \ | noremap <buffer> <C-]> :TagImposterAnticipateJump <Bar> ALEGoToDefinition<CR>
  " \ | noremap <buffer> <C-t> <C-o>h
  " \ | noremap <buffer> <C-]> :LspDefinition<CR>
  " \ | noremap <buffer> <C-]> :call LanguageClient#textDocument_definition()<CR>
  " \ | noremap <buffer> <C-t> <C-o>
  " \ | noremap <buffer> <C-]> :TagImposterAnticipateJump <Bar> ALEGoToDefinition<CR>

au FileType ledger
  \ let b:Comment=";"
  \ | let b:EndComment=""
  \ | source ~/.vim/fourspaces.vim

au FileType tsv
  \ source ~/.vim/tabs8.vim

au FileType wini
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim

au FileType conf
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim
  \ | set indentexpr=
  \ | set smartindent

au FileType toml
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim
  \ | set indentexpr=
  \ | set smartindent

au FileType yaml
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim
  \ | set indentexpr=
  \ | set smartindent

au FileType java
  \ let b:Comment="//"
  \ | let b:EndComment=""
  \ | source ~/.vim/fourspaces.vim

au FileType javascript
  \ let b:Comment="/*"
  \ | let b:EndComment="*/"
  \ | source ~/.vim/twospaces.vim

au FileType c
  \ let b:Comment="/*"
  \ | let b:EndComment="*/"
  \ | source ~/.vim/fourspaces.vim

au FileType cpp
  \ let b:Comment="//"
  \ | let b:EndComment=""
  \ | source ~/.vim/fourspaces.vim

au FileType nginx
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/fourspaces.vim
  \ | set smartindent

au FileType tex
  \ let &mp="clear; pdflatex %"
  \ | let b:Comment="%"
  \ | let b:EndComment=""

au FileType lua
  \ let &mp="clear; lua %"
  \ | let &efm="lua: %f:%l:%m,%-G%.%#"
  \ | let b:Comment="--"
  \ | let b:EndComment=""

au FileType python
  \ let &mp="clear; python2 %"
  \ | let &efm='%A %#File "%f"\, line %l\,%.%#,%-GTrace%.%#,%C %.%#,%Z%m,%-G%.%#'
  \ | let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/fourspaces.vim

au FileType php
  \ let b:Comment="//"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim

" Make PHP use smartindent dammit!
" (This is so HTML indenting is sane.)
au BufRead,BufNewFile *.html set smartindent
au BufRead,BufNewFile *.php set smartindent
au BufRead,BufNewFile *.jgr set smartindent

au FileType haskell
  \ let &mp="clear; ghc --make %"
  \ | let &efm='%f:%l:%c:'
  \ | let b:Comment="--"
  \ | let b:EndComment=""
  \ | set smartindent

au FileType cabal
  \ let b:Comment="--"
  \ | let b:EndComment=""
  \ | set smartindent

au FileType sml
  \ let &mp="ledit -x -h ~/.ledit/mosml mosml -P full %"
  \ | let b:Comment="(*"
  \ | let b:EndComment="*)"

au FileType vim
  \ let b:Comment='"'
  \ | let b:EndComment=""

au FileType lisp
  \ let b:Comment=";"
  \ | let b:EndComment=""

au FileType sh
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim

au FileType zsh
  \ let b:Comment="#"
  \ | let b:EndComment=""
  \ | source ~/.vim/twospaces.vim

au FileType utln
  \ let &mp="clear; validate-utlnx %"
  \ | let &efm='%f\, line %#%l:%m'
  \ | let b:Comment="(X:"
  \ | let b:EndComment=")"
  \ | set smartindent

au FileType mako
  \ let b:Comment="<%doc>"
  \ | let b:EndComment="</%doc>"
  \ | set smartindent

au FileType crontab
  \ let b:Comment="#"
  \ | let b:EndComment=""

au FileType conf
  \ let b:Comment="#"
  \ | let b:EndComment=""

au FileType make
  \ let b:Comment="#"
  \ | let b:EndComment=""

au FileType html
  \ let b:Comment="<!--"
  \ | let b:EndComment="-->"

au BufEnter *.html setlocal smartindent
au BufEnter *.tpl setlocal smartindent

au FileType htmldjango
  \ let b:Comment="{% comment %}"
  \ | let b:EndComment="{% endcomment %}"

au FileType css
  \ let b:Comment="/*"
  \ | let b:EndComment="*/"

" au BufEnter * filetype detect

