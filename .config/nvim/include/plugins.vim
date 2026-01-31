call plug#begin(stdpath('data') . '/plugged')

" The standard Rust vim plugin. There's quite a bit of overlap with LSPs here,
" but it has useful settings for indentation and what not.
"
" I use my own fork of this with some minor customizations. It would probably
" be good to get them upstreamed, but the repo hasn't been active for two
" years. And I suspect it would be work to convince people that my changes
" are good for everyone.
Plug 'BurntSushi/rust.vim', { 'branch': 'burntsushi' }

" Plugin for interacting with Jinga template files.
Plug 'Glench/Vim-Jinja2-Syntax'

" Bulk renaming of files in vim.
Plug 'qpkorr/vim-renamer'

" Convenient HTTP interactions within vim. Use \tt to run an HTTP request.
Plug 'aquach/vim-http-client'

" TOML syntax support.
Plug 'cespare/vim-toml'

" Go plugin.
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" FZF plugin for fuzzy searching files.
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" I tried `nvim-cmp` and did get it to work, but...
" So much shit just for completions? I don't get it.
" The configuration require is INSANE. Thankfully
" the `blink` project seems to have better sensibilities.
Plug 'saghen/blink.cmp'

" The config is so complicated, I guess we should
" just bring in a community maintained one.
Plug 'neovim/nvim-lspconfig'

" For autowrapping function declarations.
Plug 'FooSoft/vim-argwrap'
nnoremap <silent> \q :ArgWrap<CR>
let g:argwrap_tail_comma = 1

" Install common neovim LSP client configurations.
" Plug 'neovim/nvim-lsp'
" TODO: There appears to currently be a bug where nvim-lsp always reports a
" syntax error at the bottom of a Rust source file. So use COC for now.
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" This plugin is used to configure how nvim-lsp displays errors/diagnostics.
" TODO: Since we're using COC for now, we don't need this.
" Plug 'haorenW1025/diagnostic-nvim'
" let g:diagnostic_insert_delay = 1
" let g:diagnostic_enable_virtual_text = 1

" We use ALE for Go, because it supports additional linting tools.
Plug 'dense-analysis/ale'
let g:ale_linters = {
      \ 'go': ['gofmt', 'golint', 'go vet', 'go build', 'gosimple']
      \ }
let g:ale_lint_on_enter = 1
let g:ale_lint_on_filetype_changed = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_completion_enabled = 0
" N.B. This is the default value, but it serves as a reminder that vim
" on Ubuntu 18.04 is broken. Namely, the cursor disappears on any line
" that echos an error message in the status bar. The way to fix this is to
" install an updated version of vim:
"
"     sudo add-apt-repository ppa:jonathonf/vim
"     sudo apt-get update
"     sudo apt-get upgrade
"
" Presumably this doesn't impact neovim, since we use the latest pre-release.
let g:ale_echo_cursor = 1

" This must be called before importing any Lua modules added above.
call plug#end()

" Configure Rust LSP plugin.
" This apparently must be here, before ftdetect loads lang-specific settings.
"
" TODO: There appears to currently be a bug where nvim-lsp always reports a
" syntax error at the bottom of a Rust source file. So use COC for now.
" lua <<EOF
" -- local lsp = require 'nvim_lsp'
" -- lsp.rust_analyzer.setup({
" -- })
" require'nvim_lsp'.rust_analyzer.setup{
" --  on_attach = require'diagnostic'.on_attach,
" }
" --  settings = {
" --    ["rust-analyzer"] = {
" --      checkOnSave = {
" --        enable = true;
" --      },
" --      diagnostics = {
" --        enable = false;
" --      }
" --    }
" --  }
" --}
" EOF
