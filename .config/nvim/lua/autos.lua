-- A collection of random autocmds.
-- For lang specific autocmd, see `lua/lang.lua`.

-- Strips trailing whitespace from every line in the current buffer.
function strip_trailing_whitespace()
  local line = vim.fn.line('.')
  local column = vim.fn.col('.')
  vim.cmd([[%s/\s\+$//e]])
  -- Put the cursor back where it was.
  -- Without this, the `%s` command
  -- will put the cursor after the last
  -- trailing whitespace match.
  vim.fn.cursor(line, column)
end

-- Strip trailing whitespace on save.
-- ... unless NEOVIM_PRESERVE_TRAILING_WHITESPACE
-- is set. Because I guess sometimes we want
-- to preserve it.
if vim.env.NEOVIM_PRESERVE_TRAILING_WHITESPACE ~= '1' then
  vim.api.nvim_create_autocmd('BufWritePre', {
    callback = strip_trailing_whitespace,
  })
end

-- Force reload of files that change on disk outside of vim.
-- See also `autoread` in `lua/options.lua`.
vim.api.nvim_create_autocmd(
  {'FocusGained', 'BufEnter', 'BufWinEnter', 'CursorHold', 'CursorHoldI'},
  {
    callback = function()
      if vim.fn.mode() ~= 'c' then
        vim.cmd.checktime()
      end
    end,
  }
)
-- Emits a warning if the file changed.
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  callback = function()
    vim.cmd.echohl('WarningMsg')
    vim.cmd.echo([["File changed on disk. Buffer reloaded."]])
    vim.cmd.echohl('None')
  end,
})
