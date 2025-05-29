" Convenience for inserting a newline from normal mode.
noremap Q :put=''<CR>

" Hitting escape twice should clear any search highlights.
nnoremap <ESC><ESC> :nohlsearch<CR>

" CTRL-S saves current buffer. Muscle memory from Windows years ago.
noremap <C-s> :w<CR>
inoremap <C-s> <ESC>l:w<CR>

" Keybindings for invoking 'par' to reflow text.
" 'f' is for reflowing to shorter lines, usually for commit messages.
" 'g' is for standard 79 columns with 4 space tabs.
" 'h' is for 100 columns and 4 space tabs (Astral style).
vnoremap <Leader>f !par T4 'B=.,?_A_a' 71qr<CR>
nmap <Leader>f <S-v><Leader>f
vnoremap <Leader>g !par T4 'B=.,?_A_a' 79qr<CR>
nmap <Leader>g <S-v><Leader>g
vnoremap <Leader>h !par T4 'B=.,?_A_a' 100qr<CR>
nmap <Leader>h <S-v><Leader>h

" Conveniences for base64 encoding/decoding. For encoding, we strip the
" trailing newline to make inline base64 encoding work as one would expect.
:vnoremap <Leader>d64 c<C-R>=system('base64 --decode', @")<CR><ESC>
:vnoremap <Leader>e64 c<C-R>=system('base64 \| head -c -1', @")<CR><ESC>
" Similarly, another keybinding for JSON prettifying. Note that this is
" line oriented and won't respect more precise selections.
:vnoremap <Leader>j !jq .<CR>

" :vnoremap <Leader>d64 !base64 --decode<CR>
" :vnoremap <Leader>e64 !base64<CR>

" Convenience keybinding for writing the current date.
noremap <Leader>d :read !date +"\%B \%-d, \%Y"<CR>

" Writer dividers equivalence to the length of the previous line.
fun! Divider(char)
  let len = strlen(getline('.'))
  call append('.', repeat(a:char, len))
  normal j
endfun
noremap <Leader>= :call Divider('=')<CR>
noremap <Leader>- :call Divider('-')<CR>
noremap <Leader>~ :call Divider('~')<CR>

" Shortcut for reloading neovim config.
noremap <F2> :source ~/.config/nvim/init.vim<CR>
" Apparently this is necessary to fix broken syntax highlighting sometimes.
noremap <F10> :syntax sync fromstart<CR>
" Shortcut for enabling text mode.
noremap <F12> :source ~/.config/nvim/include/spacing/text.vim<CR>

" Shortcut for writing current file with 'sudo'.
command! W w !sudo tee % > /dev/null

" fzf entrypoint.
nmap <Leader>b :Buffers<CR>
nmap <Leader>e :Files<CR>
" ripgrep entrypoint.
nmap <Leader>r :Rg<CR>
