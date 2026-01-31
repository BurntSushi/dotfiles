function copy_github_perma_link_with_line_number()
  local path = vim.fn.expand('%:p')
  local firstline = vim.fn.getpos('v')[2]
  local lastline = vim.fn.getpos('.')[2]
  local cmd = {'github-link', '--clip', path, firstline}
  if firstline ~= lastline then
    table.insert(cmd, lastline)
  end
  vim.fn.system(cmd)
  vim.api.nvim_input('<ESC>')
end
vim.keymap.set({'n', 'v'}, [[\ll]], copy_github_perma_link_with_line_number)

function copy_github_perma_link()
  local path = vim.fn.expand('%:p')
  vim.fn.system({'github-link', '--clip', path})
end
vim.keymap.set({'n', 'v'}, [[\l]], copy_github_perma_link)
