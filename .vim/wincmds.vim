function! WinMove(key) 
  let l:curwin = winnr()
  exec "wincmd " . a:key
  if (l:curwin == winnr()) "we havent moved
    let l:curview = winsaveview()
    if match(a:key, '[jk]') > -1 "were we going up/down
      wincmd s
    else 
      wincmd v
    endif
    call winrestview(l:curview)
    exec "wincmd " . a:key
    call winrestview(l:curview)
  endif
endfunction
 
map <C-W>h    :call WinMove('h')<cr>
map <C-W>k    :call WinMove('k')<cr>
map <C-W>l    :call WinMove('l')<cr>
map <C-W>j    :call WinMove('j')<cr>

map <C-left>  :wincmd <<cr>
map <C-right> :wincmd ><cr>
map <C-up>    :wincmd +<cr>
map <C-down>  :wincmd -<cr>

