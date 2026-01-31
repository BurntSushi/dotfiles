-- I'm trying out neovide (so bootiful), and this needs to be set first:
-- https://github.com/Kethku/neovide/tree/0b976c3d28bbd24e6c83a2efc077aa96dde1e9eb#troubleshooting
vim.opt.guifont = 'Hack Nerd Font:h16'

require 'plugins'

-- Specifically global so that they can be called interactively.
spacing = require 'spacing'

require 'options'
require 'style'

require 'autos'
require 'comment'
require 'githublink'
require 'windows'

require 'keybinds'
require 'lang'
require 'lsp'
