" Make CTRL-T work correctly with goto-definition.
setlocal tagfunc=CocTagFunc

nmap <Leader>gt <Plug>(coc-type-definition)
nmap <Leader>gre <Plug>(coc-references)
nmap <Leader>gi <Plug>(coc-implementation)
nmap <Leader>grn <Plug>(coc-rename)
nmap <Leader>gd <Plug>(coc-diagnostic-info)
nmap <Leader>gp <Plug>(coc-diagnostic-prev)
nmap <Leader>gn <Plug>(coc-diagnostic-next)

" Forcefully disable ALE, which seems to be starting despite me not
" configuring it for Rust...
let g:ale_enabled = 0
