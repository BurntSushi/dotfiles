-- Just a collection of utility functions I've picked up.

return {
  is_visual_mode = function()
    local mode = vim.api.nvim_get_mode().mode
    return mode == 'v' or mode == 'V' or mode == '\x16'
  end,

  escape_visual_mode = function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<ESC>', true, false, true),
      -- 'n' means Normal mode
      -- 'x' ensures keycodes are processed correctly after <ESC>
      'nx',
      false
    )
  end,
}
