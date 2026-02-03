-- Convenience for inserting a newline from normal mode.
vim.keymap.set('n', 'Q', function() vim.api.nvim_put({''}, 'l', true, false) end)

-- Hitting escape twice should clear any search highlights.
vim.keymap.set('n', '<ESC><ESC>', vim.cmd.nohlsearch)

-- CTRL-S saves current buffer. Muscle memory from Windows years ago.
vim.keymap.set('n', '<C-s>', vim.cmd.write)
vim.keymap.set('i', '<C-s>', vim.cmd.write)

-- Keybindings for invoking 'par' to reflow text.
-- 'f' is for reflowing to shorter lines, usually for commit messages.
-- 'g' is for standard 79 columns with 4 space tabs.
-- 'h' is for 100 columns and 4 space tabs (Astral style).
local short = [[par T4 'B=.,?_A_a' 71qr<CR>]]
local medium = [[par T4 'B=.,?_A_a' 79qr<CR>]]
local long = [[par T4 'B=.,?_A_a' 100qr<CR>]]
vim.keymap.set('v', [[\f]], string.format('!%s', short))
vim.keymap.set('n', [[\f]], string.format('<S-v>!%s', short))
vim.keymap.set('v', [[\g]], string.format('!%s', medium))
vim.keymap.set('n', [[\g]], string.format('<S-v>!%s', medium))
vim.keymap.set('v', [[\h]], string.format('!%s', long))
vim.keymap.set('n', [[\h]], string.format('<S-v>!%s', long))

-- A nice shortcut for breaking up a line (like a function call).
-- Also works in reverse!
vim.keymap.set('n', [[\qw]], ':ArgWrap<CR>', { silent = true })

-- Conveniences for base64 encoding/decoding. For encoding, we strip the
-- trailing newline to make inline base64 encoding work as one would expect.
-- :vnoremap <Leader>d64 c<C-R>=system('base64 --decode', @")<CR><ESC>
-- :vnoremap <Leader>e64 c<C-R>=system('base64 \| head -c -1', @")<CR><ESC>
vim.keymap.set('v', [[\d64]], [[c<C-R>=system('base64 --decode', @")<CR><ESC>]])
vim.keymap.set('v', [[\e64]], [[c<C-R>=system('base64 | head -c -1', @")<CR><ESC>]])
-- Similarly, another keybinding for JSON prettifying. Note that this is
-- line oriented and won't respect more precise selections.
vim.keymap.set('v', [[\j]], '!jq .<CR>')

-- Convenience keybinding for writing the current date.
vim.keymap.set('n', [[\cd]], function()
  local now = vim.fn.system({'biff', 'time', 'fmt', '-f', '%B %-d, %Y', 'now'})
  vim.api.nvim_put({vim.fn.trim(now)}, 'l', true, false)
end)

-- Writer dividers equivalence to the length of the previous line.
local divider = function(char)
  return function()
    local len = string.len(vim.fn.getline('.'))
    vim.print(len)
    vim.fn.append('.', string.rep(char, len))
    vim.cmd.normal('j')
  end
end
vim.keymap.set('n', [[\=]], divider('='))
vim.keymap.set('n', [[\-]], divider('-'))
vim.keymap.set('n', [[\~]], divider('~'))

-- Apparently this is necessary to fix broken syntax highlighting sometimes.
vim.keymap.set('n', '<F10>', function() vim.cmd.syntax('sync', 'fromstart') end)

-- Shortcut for enabling text mode.
vim.keymap.set('n', '<F12>', function()
  spacing.text()
  vim.print('TEXT MODE')
end)

-- Shortcut for writing current file with 'sudo'.
vim.api.nvim_create_user_command('W', 'w !sudo tee % > /dev/null', {})

-- fzf entrypoint.
vim.keymap.set('n', [[\b]], ':Buffers<CR>')
vim.keymap.set('n', [[\e]], ':Files<CR>')

-- ripgrep entrypoint.
vim.keymap.set('n', [[\r]], ':Rg<CR>')

-- Tweak some telescope keybindings.
local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    initial_mode = 'normal',
    mappings = {
      i = {
        -- ["<ESC>"] = actions.close,
        ["<Tab>"] = actions.move_selection_next,
        ["<S-Tab>"] = actions.move_selection_previous,
      },
      n = {
        ["<ESC>"] = actions.close,
        ["<Tab>"] = actions.move_selection_next,
        ["<S-Tab>"] = actions.move_selection_previous,
      },
    },
  },
})
