local spacing = require 'spacing'

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c',
  callback = function()
    spacing.space4()
    vim.b.comment = '/*'
    vim.b.end_comment = '*/'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cabal',
  callback = function()
    spacing.space2()
    vim.b.comment = '--'
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'conf',
  callback = function()
    spacing.space2()
    vim.b.comment = '#'
    vim.opt_local.indentexpr = ''
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cpp',
  callback = function()
    spacing.space4()
    vim.b.comment = '//'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'crontab',
  callback = function()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cs',
  callback = function()
    spacing.space2()
    vim.b.comment = '//'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'css',
  callback = function()
    spacing.space4()
    vim.b.comment = '/*'
    vim.b.end_comment = '*/'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dot',
  callback = function()
    spacing.space4()
    vim.b.comment = '//'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    spacing.tab8()
    vim.b.comment = '//'
    -- My old vim config follows. I don't
    -- really use Go much any more, so I
    -- didn't bother trying to port this.
    --
    -- noremap <Leader>i :GoImports<CR>
    -- let g:gofmt_command="goimports"
    -- let g:go_jump_to_error = 0
    -- let g:go_autodetect_gopath = 0
    -- let g:go_template_autocreate = 0
    -- let g:go_def_mode='gopls'
    -- let g:go_def_mapping_enabled = 1
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'haskell',
  callback = function()
    spacing.space4()
    vim.b.comment = '--'
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'html',
  callback = function()
    spacing.space4()
    vim.b.comment = '<!--'
    vim.b.end_comment = '-->'
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'javascript',
  callback = function()
    spacing.space2()
    vim.b.comment = '/*'
    vim.b.end_comment = '*/'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'json',
  callback = spacing.space4,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ledger',
  callback = function()
    spacing.space4()
    vim.b.comment = ';'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lisp',
  callback = function()
    spacing.space2()
    vim.b.comment = ';'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    spacing.space2()
    vim.b.comment = '--'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'make',
  callback = function()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'mako',
  callback = function()
    spacing.space2()
    vim.b.comment = '<%doc>'
    vim.b.end_comment = '</%doc>'
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = spacing.space2,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'nginx',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'perl',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'php',
  callback = function()
    spacing.space2()
    vim.b.comment = '//'
    vim.opt_local.smartindent = true
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    spacing.space4()
    vim.b.comment = '//'

    -- Make syntax highlighting more efficient.
    vim.cmd.syntax({'sync', 'fromstart'})
    -- "recommended style" uses 99-column lines. No thanks.
    vim.g.rust_recommended_style = 0

    -- Always run rustfmt always use stable. Back in the days of yore,
    -- I used to only run rustfmt if a rustfmt.toml file was present.
    -- I think I did that because I didn't want to use rustfmt in all
    -- cases back then. But I've evolved.
    vim.g.rustfmt_autosave = 1
    vim.g.rustfmt_autosave_if_config_present = 0
    vim.g.rustfmt_command = 'rustfmt +stable'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sh',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sml',
  callback = function()
    spacing.space2()
    vim.b.comment = '(*'
    vim.b.end_comment = '*)'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  callback = function()
    spacing.space2()
    vim.b.comment = '%'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'toml',
  callback = function()
    spacing.space2()
    vim.b.comment = '#'
    vim.opt_local.indentexpr = ''
    vim.opt_local.smartindent = true
    -- This was in my vim config. Not sure
    -- what it's doing? Hmmm. See:
    -- https://stackoverflow.com/questions/191201/indenting-comments-to-match-code-in-vim
    -- inoremap # X#
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'vim',
  callback = function()
    spacing.space2()
    vim.b.comment = '"'
  end
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'vimscript',
  callback = function()
    spacing.space2()
    vim.b.comment = '"'
  end
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'wini',
  callback = function()
    spacing.space2()
    vim.b.comment = '#'
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'yaml',
  callback = function()
    spacing.space2()
    vim.b.comment = '#'
    vim.opt_local.indentexpr = ''
    vim.opt_local.smartindent = true
    -- This was in my vim config. Not sure
    -- what it's doing? Hmmm. See:
    -- https://stackoverflow.com/questions/191201/indenting-comments-to-match-code-in-vim
    -- inoremap # X#
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'zsh',
  callback = function()
    spacing.space4()
    vim.b.comment = '#'
  end,
})
