local fns = {}

function fns.space2()
  vim.opt_local.tabstop = 2
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2
end

function fns.space4()
  vim.opt_local.tabstop = 4
  vim.opt_local.shiftwidth = 4
  vim.opt_local.softtabstop = 4
end

function fns.space8()
  vim.opt_local.tabstop = 8
  vim.opt_local.shiftwidth = 8
  vim.opt_local.softtabstop = 8
end

function fns.tab2()
  fns.space2()
  vim.opt_local.expandtab = false
end

function fns.tab4()
  fns.space4()
  vim.opt_local.expandtab = false
end

function fns.tab8()
  fns.space8()
  vim.opt_local.expandtab = false
end

function fns.text()
  fns.space2()
  vim.opt_local.textwidth = 79
  vim.opt_local.smartindent = true
end

function fns.tridactyl()
  fns.text()
  vim.opt_local.binary = true
  vim.opt_local.eol = false
  vim.opt_local.expandtab = true
end

return fns
