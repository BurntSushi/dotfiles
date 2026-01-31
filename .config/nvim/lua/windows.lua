local win_move = function(key)
  return function()
    local curwin = vim.fn.winnr()
    vim.cmd.wincmd(key)
    if curwin == vim.fn.winnr() then
      local curview = vim.fn.winsaveview()
      if key == 'j' or key == 'k' then
        vim.cmd.wincmd('s')
      else
        vim.cmd.wincmd('v')
      end
      vim.fn.winrestview(curview)
      vim.cmd.wincmd(key)
      vim.fn.winrestview(curview)
    end
  end
end

vim.keymap.set('n', '<C-W>h', win_move('h'))
vim.keymap.set('n', '<C-W>k', win_move('k'))
vim.keymap.set('n', '<C-W>l', win_move('l'))
vim.keymap.set('n', '<C-W>j', win_move('j'))
vim.keymap.set('n', '<C-left>', function() vim.cmd.wincmd('<') end)
vim.keymap.set('n', '<C-right>', function() vim.cmd.wincmd('>') end)
vim.keymap.set('n', '<C-up>', function() vim.cmd.wincmd('+') end)
vim.keymap.set('n', '<C-down>', function() vim.cmd.wincmd('-') end)
