" Show line numbers.
set number

" Always expand tabs to spaces.
set expandtab

" By default, use two space indents and don't wrap automatically.
set textwidth=0
runtime! include/spacing/two.vim

" Keep a buffer around even when abandoned.
" Without this, jump-to-definition in LSP clients seems to complain if the
" file hasn't been saved. In other words, let us go to other buffers even if
" the current one isn't saved.
set hidden

" This causes neovim to use the system clipboard for all yanking operations,
" instead of needing to use the '+' or '*' registers explicitly.
set clipboard+=unnamedplus

" Prefer xsel over xclip. With xclip, pasting into gmail/gdocs results in
" stripping all newlines. But with xsel, it works correctly.
" See: https://github.com/neovim/neovim/issues/5853
if executable('xsel')
  " This is copied directly from runtime/autoload/provider/clipboard.vim.
  let g:clipboard = {
        \   'name': 'myxsel',
        \   'copy': {
        \      '+': 'xsel --nodetach --input --clipboard',
        \      '*': 'xsel --nodetach --input --primary',
        \    },
        \   'paste': {
        \      '+': 'xsel --output --clipboard',
        \      '*': 'xsel --output --primary',
        \   },
        \   'cache_enabled': 1,
        \ }
endif

" There's no need to do syntax highlighting past this many columns. The default
" of 3000 is a bit and degrades performance.
set synmaxcol=200

" While typing a search, start highlighting results.
set incsearch

" When scrolling, always keep the cursor N lines from the edges.
set scrolloff=10

" Convenience for automatic formatting.
"   t - auto-wrap text by respecting textwidth
"   c - auto-wrap comments by respecting textwidth
"   r - auto-insert comment leading after <CR> in insert mode
"   o - auto-insert comment leading after O in normal mode
set formatoptions=tcro

" Don't switch window focus when using HTTP client.
let g:http_client_focus_output_window=0

" Don't conceal things in markup languages.
let g:pandoc#syntax#conceal#use = 0
