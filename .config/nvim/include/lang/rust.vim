" See: https://github.com/neoclide/coc.nvim#example-vim-configuration

" For custom commenting functions.
let b:Comment="//"
let b:EndComment=""

" Four space indents.
runtime! include/spacing/four.vim

" Make syntax highlighting more efficient.
syntax sync fromstart

" 'recommended style' uses 99-column lines. No thanks.
let g:rust_recommended_style = 0

" Always run rustfmt always use stable. Back in the days of yore,
" I used to only run rustfmt if a rustfmt.toml file was present.
" I think I did that because I didn't want to use rustfmt in all
" cases back then. But I've evolved.
let g:rustfmt_autosave = 1
let g:rustfmt_autosave_if_config_present = 0
let g:rustfmt_command = "rustfmt +stable"

" Make CTRL-T work correctly with goto-definition.
" setlocal tagfunc=CocTagFunc

" nmap <Leader>gt <Plug>(coc-type-definition)
" nmap <Leader>gre <Plug>(coc-references)
" nmap <Leader>gi <Plug>(coc-implementation)
" nmap <Leader>grn <Plug>(coc-rename)
" nmap <Leader>gd <Plug>(coc-diagnostic-info)
" nmap <Leader>gp <Plug>(coc-diagnostic-prev)
" nmap <Leader>gn <Plug>(coc-diagnostic-next)

" Trigger auto-completion with C-space.
" inoremap <silent><expr> <c-space> coc#refresh()
" Make <TAB> select next completion and Shift-<TAB> to select previous.
" inoremap <silent><expr> <TAB>
      " \ coc#pum#visible() ? coc#pum#next(1) :
      " \ CheckBackspace() ? "\<Tab>" :
      " \ coc#refresh()
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" function! CheckBackspace() abort
  " let col = col('.') - 1
  " return !col || getline('.')[col - 1]  =~# '\s'
" endfunction
" Make <CR> confirm completion.
" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              " \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Forcefully disable ALE, which seems to be starting despite me not
" configuring it for Rust...
let g:ale_enabled = 0
