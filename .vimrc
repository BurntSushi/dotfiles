" set runtimepath^=~/.vim/bundle/rust.vim
set nocompatible
set t_Co=256

if $TERM == 'screen-256color'
  colorscheme ron
elseif $TERM == 'linux'
  colorscheme peachpuff
else
  colorscheme summerfruit256
  " let molokai_original=1
  " colorscheme molokai
endif

syntax on

set directory=$HOME/.vim/swapfiles
set synmaxcol=200
set incsearch
set showcmd
set number
set scrolloff=10
set hlsearch
set expandtab
set nosmartindent
set showmatch
set wildmode=list:longest,full
set wildmenu
set hidden
set mouse=a
set formatoptions=tcqrow
set shell=/bin/bash
set clipboard=unnamedplus " Use + register as unnamed register
set foldlevel=99
set spellcapcheck= " Have no need for this.
" Let modelines set things like indentexpr
if has("modelineexpr")
  set modelineexpr
endif
" set autochdir
if exists('+colorcolumn')
  set colorcolumn=80
endif

set tabstop=2
set shiftwidth=2
set softtabstop=2

" The vim latex plugin PKGBUILD says I need this
set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"
let g:Tex_DefaultTargetFormat = "pdf"
let g:Tex_MultipleCompileFormats = "dvi,pdf"
let g:Tex_IgnoredWarnings =
      \ "Underfull\n" .
      \ "Overfull\n" .
      \ "specifier changed to\n" .
      \ "You have requested\n" .
      \ "Missing number, treated as zero.\n" .
      \ "There were undefined references\n" .
      \ "Citation %.%# undefined\n" .
      \ "LaTeX Font Warning:\n" .
      \ "Marginpar\n" .
      \ "Empty `thebibliography' environment\n"
let g:Tex_IgnoreLevel = 10
let g:Tex_GotoError = 0

" In case I want to use solarized
let g:solarized_termcolors=256

" Don't outdent PHP tags
let g:PHP_outdentphpescape = 0

" Umm. No.
let g:rust_recommended_style = 0
let g:rustfmt_autosave_if_config_present = 1
let g:rustfmt_command = "rustfmt +stable"

" Don't switch window focus when using HTTP client.
let g:http_client_focus_output_window=0

source ~/.vim/langvars.vim
source ~/.vim/wincmds.vim

filetype plugin indent on

if !exists("b:Comment")
    let b:Comment="" | let b:EndComment=""
endif

fun! RegexLiteral(str)
    return escape(a:str, "*$.^/")
endfun

fun! CommentLines()
    if b:Comment != ""
        exe ":s/^\\(\\s*\\)/\\1".escape(b:Comment, '/')." /e"
        exe ":s/$/ ".escape(b:EndComment, '/')."/e"
    endif
endfun

fun! UncommentLines()
    exe ":s/^\\(\\s*\\)".RegexLiteral(b:Comment)."\\s*/\\1/e"
    exe ":s/\\s*".RegexLiteral(b:EndComment)."\\s*$//e"
endfun

fun! GlobalReplace()
  normal! gv"ry
  let replacement = input("Replace " . @r . " with: ")
  if replacement != ""
    exe "%s/" . @r . "/" . replacement . "/g"
  endif
endfun

fun! Divider(char)
  let len = strlen(getline('.'))
  call append('.', repeat(a:char, len))
  normal j
endfun

fun! StripTrailingWhitespace()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun

autocmd BufWritePre * :call StripTrailingWhitespace()

map Q :put=''<CR>
map <tab> :tabn<CR>
map <S-tab> :tabp<CR>
map <C-F4> :close<CR>
map <C-n> :tabnew<CR>
"map <Up> gk
"map <Down> gj
map <C-z> :sh<CR>
map <C-s> :w<CR>
map ,, :call CommentLines()<CR>
map ,. :call UncommentLines()<CR>
map ,r :call ReadReport105()<CR>>>Qkgq<CR><CR>
map <C-s> :w<CR><C-l>

map <F2> :source ~/.vimrc<CR>
map <F4> "ayy@a<CR>
map <F5> :w<CR>:make<CR>
map <F6> :filetype detect<CR>
map <F10> :syntax sync fromstart<CR>
map <F12> :source ~/.vim/text.vim<CR>

map \d :read !date +"\%B \%-d, \%Y"<CR>
map \= :call Divider('=')<CR>
map \- :call Divider('-')<CR>
map \~ :call Divider('~')<CR>
nmap \e :Files<CR>
nmap \r :Rg<CR>
vmap \f !par T4 B=.,?_A_a 71qr<CR>
nmap \f <S-v>\f
vmap \g !par T4 B=.,?_A_a 79qr<CR>
nmap \g <S-v>\g
vmap \h !par T8 B=.,?_A_a 79qr<CR>
nmap \h <S-v>\h
map \i :GoImports<CR>

nnoremap <silent> <ESC><ESC> :noh<CR>
vnoremap <silent> & :call GlobalReplace()<CR>
vnoremap * y/<C-R>"<CR>

imap <C-s> <ESC><C-s>
imap <F5> <ESC><F5>

" Use 'very magic' regexes by default. There appears to be no way to set this
" otherwise. 'very magic' basically means 'use extended regexes'.
"
" Turns out, I like plain 'magic', because it reduces the need to use escaping
" a lot more. Blech.
" nnoremap / /\v
" vnoremap / /\v

command! W w !sudo tee % > /dev/null

" Syntastic configuration.
let g:syntastic_python_checkers = ['flake8']
"let g:syntastic_python_pyflakes_exec = 'pyflakes-python2'
"let g:syntastic_python_flake8_exec = 'flake8-python2'
let g:syntastic_python_pyflakes_exec = 'pyflakes'
let g:syntastic_python_flake8_exec = 'flake8'
let g:syntastic_auto_loc_list = 0
let g:go_jump_to_error = 0
let g:go_autodetect_gopath = 0
let g:go_template_autocreate = 0
let g:go_def_mode='gopls'
let g:go_def_mapping_enabled = 1
" let g:syntastic_go_checkers = ['go', 'gofmt', 'golint', 'govet', 'errcheck']
let g:syntastic_go_checkers = []
let g:syntastic_rust_checkers = []
" let g:syntastic_rust_checkers = ['rustc']
" let g:syntastic_rust_rustc_args = '-Zparse-only'
" let g:syntastic_rust_checkers = []

" Pandoc/markdown config.
let g:pandoc#syntax#conceal#use = 0

" Plug config.
call plug#begin('~/.vim/plugged')

" Plug 'autozimu/LanguageClient-neovim', {
      " \ 'branch': 'next',
      " \ 'do': 'bash install.sh',
      " \ }
" let g:LanguageClient_serverCommands = {
      " \ 'rust': ['rustup', 'run', 'stable', 'rls'],
      " \ }

" Plug 'prabirshrestha/async.vim'
" Plug 'prabirshrestha/vim-lsp'
"
" if executable('rls')
  " au User lsp_setup call lsp#register_server({
        " \ 'name': 'rls',
        " \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
        " \ 'whitelist': ['rust'],
        " \ })
" endif

" The standard Rust vim plugin. There's quite a bit of overlap with ALE here,
" but it has useful settings for indentation and what not.
Plug 'rust-lang/rust.vim'

" This permits easily manipulating the tag stack with a hack. See the Rust
" jump-to-definition key binding for an example.
Plug 'idbrii/vim-tagimposter'

" Bulk renaming of files in vim.
Plug 'qpkorr/vim-renamer'

" TOML syntax support.
Plug 'cespare/vim-toml'

" Go plugin.
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Syntastic, which drives the Go plugin.
Plug 'vim-syntastic/syntastic'

" FZF plugin for fuzzy searching files.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Kind of like Syntastic, but has language server support.
Plug 'dense-analysis/ale'
let g:ale_linters = {
      \ 'rust': ['cargo', 'rls'],
      \ 'go': ['gofmt', 'golint', 'go vet', 'go build', 'gosimple']
      \ }
let g:ale_rust_rls_executable = 'rust-analyzer'
" let g:ale_rust_rls_toolchain = 'stable'
let g:ale_rust_rls_config = {
      \ 'rust': { 'clippy_preference': 'off', 'feature_flags': {'lsp.diagnostics': 0} },
      \ 'feature_flags': { 'lsp.diagnostics': 0 }
      \ }
let g:ale_lint_on_enter = 1
let g:ale_lint_on_filetype_changed = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_completion_enabled = 0
let g:ale_rust_cargo_default_feature_behavior = 'all'
" N.B. This is the default value, but it serves as a reminder that vim
" on Ubuntu 18.04 is broken. Namely, the cursor disappears on any line
" that echos an error message in the status bar. The way to fix this is to
" install an updated version of vim:
"
"     sudo add-apt-repository ppa:jonathonf/vim
"     sudo apt-get update
"     sudo apt-get upgrade
let g:ale_echo_cursor = 1

" For autowrapping function declarations.
Plug 'FooSoft/vim-argwrap'
nnoremap <silent> \q :ArgWrap<CR>
let g:argwrap_tail_comma = 1

call plug#end()

filetype detect
