let b:Comment="//"
let b:EndComment=""
runtime! include/spacing/eight.vim
setlocal noexpandtab
setlocal colorcolumn=100
noremap <Leader>i :GoImports<CR>

let g:gofmt_command="goimports"
let g:go_jump_to_error = 0
let g:go_autodetect_gopath = 0
let g:go_template_autocreate = 0
let g:go_def_mode='gopls'
let g:go_def_mapping_enabled = 1
