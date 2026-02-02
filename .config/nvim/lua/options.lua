-- TODO: Configure some undo niceties?
-- https://neovim.io/doc/user/lua.html#vim.hl
-- https://neovim.io/doc/user/undo.html#undo-persistence

-- Show line numbers.
vim.opt.number = true

-- Always expand tabs to spaces.
vim.opt.expandtab = true

-- By default, use two space indents and don't wrap automatically.
vim.opt.textwidth = 0
spacing.space2()

-- Keep a buffer around even when abandoned.
-- Without this, jump-to-definition in LSP clients seems to complain if the
-- file hasn't been saved. In other words, let us go to other buffers even if
-- the current one isn't saved.
vim.opt.hidden = true

-- This causes neovim to use the system clipboard for all yanking operations,
-- instead of needing to use the '+' or '*' registers explicitly.
vim.opt.clipboard:append('unnamedplus')

-- Always disable code folding.
vim.opt.foldenable = false

-- There's no need to do syntax highlighting past this many columns. The default
-- of 3000 is a bit big and degrades performance.
vim.opt.synmaxcol = 400

-- While typing a search, start highlighting results.
vim.opt.incsearch = true

-- When scrolling, always keep the cursor N lines from the edges.
vim.opt.scrolloff = 10

-- Convenience for automatic formatting.
--   t - auto-wrap text by respecting textwidth
--   c - auto-wrap comments by respecting textwidth
--   r - auto-insert comment leading after <CR> in insert mode
--   o - auto-insert comment leading after O in normal mode
vim.opt.formatoptions = { t = true, c = true, r = true, o = true }

-- Don't switch window focus when using HTTP client.
vim.g.http_client_focus_output_window = 0

-- Don't conceal things in markup languages.
vim.g['pandoc#syntax#conceal#use'] = 0

-- I use blink for completions now.
vim.opt.wildmenu = false
-- When there's more than one match, complete the longest common prefix among
-- them and show the rest of the options.
--
-- (Useful if I ever switch back to the default wildmenu.)
-- vim.o.wildmode = 'list:longest,full'

-- Disable neovim's built-in completions.
vim.opt.complete = nil
vim.opt.completeopt = 'noselect'

-- Make sure `autoread` is enabled. To be honest, I don't actually know what
-- this does. The docs seems to suggest it will result in automatically
-- reloading a file if it has been detected to change AND if there are no
-- changes made to the corresponding buffer. But I run into this situation all
-- the time where neovim does *not* automatically reload the file. (For
-- example, after running `cargo insta accept` for inline snapshots.)
--
-- Anyway... we try to fix `autoread`'s apparent deficiencies with an autocmd
-- hammer below[1].
--
-- OK, apparently, `autoread` does work, but just not like how it's
-- documented[2].
--
-- Note that `lua/autos.lua` contains some autocmds related to this.
--
-- [1]: https://old.reddit.com/r/neovim/comments/f0qx2y/automatically_reload_file_if_contents_changed/
-- [2]: https://github.com/neovim/neovim/issues/1936
vim.opt.autoread = true

-- Make copy/paste from the unnamed register work well.
-- I don't remember exactly why I need this.
if vim.fn.executable('xsel') == 1 then
  -- Adapted from runtime/autoload/provider/clipboard.vim.
  vim.g.clipboard = {
    name = 'myxsel',
    copy = {
      ['+'] = 'xsel --nodetach --input --clipboard',
      ['*'] = 'xsel --nodetach --input --primary',
    },
    paste = {
      ['+'] = 'xsel --output --clipboard',
      ['*'] = 'xsel --output --primary',
    },
    cache_enabled = 1,
  }
end
