require('blink.cmp').setup({
  -- Hitting enter to select something is the natural thing.
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
    -- I thought I wanted this, but it's actually pretty annoying. I end up
    -- having to hit <ESC> twice a lot to get back into normal mode.
    -- ['<ESC>'] = { 'cancel', 'fallback' },
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = false,
      },
    },
    documentation = {
      auto_show = true,
    },
    list = {
      selection = {
        auto_insert = true,
        preselect = false,
      },
    },
  },
  signature = {
    enabled = true,
  },
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
  cmdline = {
    keymap = {
      preset = 'inherit',
      ['<Tab>'] = { 'show', 'select_next', 'fallback' },
      ['<CR>'] = { 'accept_and_enter', 'fallback' },
    },
    completion = {
      list = {
        selection = {
          auto_insert = true,
          preselect = true,
        },
      },
      menu = {
        auto_show = false,
      },
    },
  },
})
