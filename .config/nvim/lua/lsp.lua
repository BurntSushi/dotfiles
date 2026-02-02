require('blink.cmp').setup({
  -- Hitting enter to select something is the natural thing.
  keymap = { preset = 'enter' },
  sources = {
    -- I don't want completions from anything else.
    default = {'lsp'},
  },
  fuzzy = {
    -- implementation = 'prefer_rust_with_warning',
    implementation = 'lua',
    -- N.B. I couldn't get this working. So just use
    -- their Lua implementation. Which seems pretty
    -- snappy?
    prebuilt_binaries = {
      download = true,
      ignore_version_mismatch = true,
      force_version = nil,
    },
  },
})

vim.lsp.config('ty', {
  cmd = { '/home/andrew/bin/astral/run-ty-server' },
  trace = 'verbose',
  init_options = {
    logLevel = 'debug',
    logFile = '/tmp/neovim-ty-tracing.log',
  },
  settings = {
    ty = {
      completions = {
        autoImport = true,
      },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  cmd = { '/home/andrew/bin/rust-analyzer-wrapper' },
  filetypes = { 'rust' },
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        targetDir = '/home/andrew/tmp/target-rust-analyzer',
      },
      diagnostics = {
        enable = true,
        disabled = {
          'inactive-code',
          'incorrect-ident-case',
          'unlinked-file',
          'unresolved-macro-call',
          'unresolved-proc-macro',
        },
      },
      procMacro = {
        enable = true,
      },
      semanticHighlighting = {
        comments = {
          enable = false,
        },
        doc = {
          comment = {
            inject = {
              enable = false;
            },
          },
        },
        nonStandardTokens = false;
        operator = {
          enable = false,
        },
        strings = {
          enable = false,
        },
      },
    }
  },
})

vim.lsp.config('lua_ls', {
  -- N.B. This is not quite right, but I only really use Lua these days inside
  -- neovim. So just recognize my `init.lua` as the root of my workspace.
  root_markers = {'init.lua'},
  on_init = function(client)
    client.config.settings.Lua = vim.tbl_deep_extend(
      'force',
      client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      }
    )
  end,
  settings = {
    Lua = {},
  },
})

-- Hide all semantic highlights. Maybe I'll enable this some day, but
-- as of right now, I don't like it.
for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
  vim.api.nvim_set_hl(0, group, {})
end

-- Function for conveniently restarting the LSP. Why isn't this built
-- into neovim???
function RestartLSP()
    print('Restarting all attached LSP clients and reloading buffer...')
    vim.lsp.stop_client(vim.lsp.get_clients())
    vim.cmd('write')
    vim.cmd('edit')
end

-- Get rid of the default keybindings.
-- I had configured my own (that are
-- very similar to these) when I used
-- CoC, and I don't feel like re-learning
-- them.
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'grt')
vim.keymap.del('n', 'gO')

-- Define the keybindings I used for CoC.
-- Nice thing is that this should work for
-- all LSP servers.
vim.keymap.set('n', [[\grn]], vim.lsp.buf.rename)
vim.keymap.set('n', [[\grr]], vim.lsp.buf.references)
vim.keymap.set('n', [[\ga]], vim.lsp.buf.code_action)
vim.keymap.set('n', [[\gi]], vim.lsp.buf.implementation)
vim.keymap.set('n', [[\gt]], vim.lsp.buf.type_definition)
vim.keymap.set('n', [[\gl]], vim.lsp.buf.declaration)
vim.keymap.set('n', [[\gO]], vim.lsp.buf.document_symbol)
vim.keymap.set('n', [[\gs]], vim.lsp.buf.signature_help)
vim.keymap.set('n', [[\gd]], vim.diagnostic.open_float)
vim.keymap.set('n', [[<C-d>]], vim.diagnostic.open_float)
vim.keymap.set('n', [[\gh]], vim.lsp.buf.typehierarchy)

vim.lsp.enable('ty')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('lua_ls')
