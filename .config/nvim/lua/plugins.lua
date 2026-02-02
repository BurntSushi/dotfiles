local plugged_path = vim.fn.stdpath('data') .. '/plugged'
vim.call('plug#begin', plugged_path)
local plug = vim.fn['plug#']

-- The standard Rust vim plugin. There's quite a bit of overlap with LSPs here,
-- but it has useful settings for indentation and what not.
--
-- I use my own fork of this with some minor customizations. It would probably
-- be good to get them upstreamed, but the repo hasn't been active for two
-- years. And I suspect it would be work to convince people that my changes
-- are good for everyone.
plug('BurntSushi/rust.vim', { branch = 'burntsushi' })

-- Plugin for interacting with Jinga template files.
-- Not sure I need this?
-- Plug('Glench/Vim-Jinja2-Syntax')

-- Bulk renaming of files in vim.
plug('qpkorr/vim-renamer')

-- Convenient HTTP interactions within vim. Use \tt to run an HTTP request.
plug('aquach/vim-http-client')

-- TOML syntax support.
plug('cespare/vim-toml')

-- Go plugin. Re-enable this if I start writing Go again.
-- plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })

-- FZF plugin for fuzzy searching files.
plug('junegunn/fzf', { ['dir'] = '~/.fzf', ['do'] = './install --all' })
plug('junegunn/fzf.vim')

-- I use this for some LSP commands (like find references).
-- The default quickfix experience is very lacking.
plug('nvim-lua/plenary.nvim')
plug('nvim-telescope/telescope.nvim')

-- I tried `nvim-cmp` and did get it to work, but...
-- So much shit just for completions? I don't get it.
-- The configuration require is INSANE. Thankfully
-- the `blink` project seems to have better sensibilities.
plug('saghen/blink.cmp')

-- The rust-analyzer config is so complicated, I guess we should
-- just bring in a community maintained one.
plug('neovim/nvim-lspconfig')

-- For autowrapping function declarations.
plug('FooSoft/vim-argwrap')
vim.g.argwrap_tail_comma = 1

vim.call('plug#end')
