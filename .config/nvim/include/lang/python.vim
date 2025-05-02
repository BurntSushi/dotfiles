let &efm='%A %#File "%f"\, line %l\,%.%#,%-GTrace%.%#,%C %.%#,%Z%m,%-G%.%#'
let b:Comment="#"
let b:EndComment=""
runtime! include/spacing/four.vim

" Make CTRL-T work correctly with goto-definition.
setlocal tagfunc=CocTagFunc

nmap <Leader>gt <Plug>(coc-type-definition)
nmap <Leader>gre <Plug>(coc-references)
nmap <Leader>gi <Plug>(coc-implementation)
nmap <Leader>grn <Plug>(coc-rename)
nmap <Leader>gd <Plug>(coc-diagnostic-info)
nmap <Leader>gp <Plug>(coc-diagnostic-prev)
nmap <Leader>gn <Plug>(coc-diagnostic-next)

" Trigger auto-completion with C-space.
inoremap <silent><expr> <c-space> coc#refresh()
" Make <TAB> select next completion and Shift-<TAB> to select previous.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Make <CR> confirm completion.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Forcefully disable ALE.
let g:ale_enabled = 0
