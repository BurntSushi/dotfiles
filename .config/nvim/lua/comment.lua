-- Some quick hacks to automatically insert line-by-line comments of
-- highlighted source code. This requires that the `vim.b.comment` and
-- `vim.b.end_comment` variables are set.
--
-- Note that my previous incantation for these routines was a bit
-- simpler. I was able to use `exe` and it somehow handled the visual
-- selection case for me. But I couldn't get that to work from Lua.
-- And in particular, when I tried to insert `'<,'>` explicitly, this
-- 1) didn't work when there wasn't a visual selection and 2) would
-- give me weird "mark not set" errors. Apparently the visual selection
-- marks aren't actually set until the visual selection is *gone*? WTF.
--
-- Old implementation:
-- https://github.com/BurntSushi/dotfiles/blob/e2e96ca22b70e4d07efa56295df84b4dc82daefe/.config/nvim/include/comment.vim

local fn = require 'fn'

vim.b.comment = ''
vim.b.end_comment = ''

local literal = function(s)
  return vim.fn.escape(s, '*$.^/')
end

local comment = function()
  if string.len(vim.b.comment) == 0 then return end
  local range = ''
  if fn.is_visual_mode() then
    fn.escape_visual_mode()
    range = [['<,'>]]
  end

  vim.cmd(range .. [[s/^\(\s*\)/\1]] .. literal(vim.b.comment) .. [[ /e]])
  if string.len(vim.b.end_comment) > 0 then
    vim.cmd(range .. [[s/$/]] .. literal(vim.b.end_comment) .. [[/e]])
  end
  vim.cmd.nohlsearch()
end

local uncomment = function()
  if string.len(vim.b.comment) == 0 then return end
  local range = ''
  if fn.is_visual_mode() then
    fn.escape_visual_mode()
    range = [['<,'>]]
  end

  vim.cmd(range .. [[s/^\(\s*\)]] .. literal(vim.b.comment) .. [[\s*/\1/e]])
  if string.len(vim.b.end_comment) > 0 then
    vim.cmd(range .. [[s/\s*]] .. literal(vim.b.end_comment) .. [[\s*$//e]])
  end
  vim.cmd.nohlsearch()
end

vim.keymap.set({'n', 'v', 'o'}, ',,', comment)
vim.keymap.set({'n', 'v', 'o'}, ',.', uncomment)
