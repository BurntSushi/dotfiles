" Show line numbers.
set number

" Always expand tabs to spaces.
set expandtab

" Keep a buffer around even when abandoned.
" Without this, jump-to-definition in LSP clients seems to complain if the
" file hasn't been saved. In other words, let us go to other buffers even if
" the current one isn't saved.
set hidden

" This causes neovim to use the system clipboard for all yanking operations,
" instead of needing to use the '+' or '*' registers explicitly.
set clipboard+=unnamedplus

" There's no need to do syntax highlighting past this many columns. The default
" of 3000 is a bit and degrades performance.
set synmaxcol=200

" While typing a search, start highlighting results.
set incsearch

" When scrolling, always keep the cursor N lines from the edges.
set scrolloff=10

" By default, use two space indents and don't wrap automatically.
set textwidth=0
runtime! include/spacing/two.vim

" Don't switch window focus when using HTTP client.
let g:http_client_focus_output_window=0

" Don't conceal things in markup languages.
let g:pandoc#syntax#conceal#use = 0
