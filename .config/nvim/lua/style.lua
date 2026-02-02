-- Force neovim to emit true colors.
vim.opt.termguicolors = true

-- Give me borders!
vim.opt.winborder = 'rounded'

-- Colors a vertical bar at the given column.
if vim.env.NEOVIM_COLOR_COLUMN == nil then
  vim.opt.colorcolumn = '80'
else
  vim.opt.colorcolumn = vim.env.NEOVIM_COLOR_COLUMN
end

-- Because dark backgrounds suck. Also, using a naturally light colorscheme
-- with a dark background ends up looking pretty bad.
vim.opt.background = 'light'

-- Beautiful theme.
vim.cmd.colorscheme('summerfruit256')
