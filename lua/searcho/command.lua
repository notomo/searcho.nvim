local M = {}

local for_search = require("searcho.lib.autocmd").for_search

local _original_cursor
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
  group = vim.api.nvim_create_augroup("searcho", {}),
  pattern = { "*" },
  callback = for_search(function()
    local cursor = _original_cursor
    _original_cursor = nil

    if not vim.v.event.abort then
      require("searcho.core.search_highlight").disable_on_next_moved()
      return
    end

    require("searcho.core.search_highlight").disable()

    local window_id = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if not (cursor and vim.api.nvim_win_is_valid(window_id)) then
        return
      end

      local bufnr = vim.api.nvim_win_get_buf(window_id)
      local count = vim.api.nvim_buf_line_count(bufnr)
      if count < cursor[1] then
        return
      end

      vim.api.nvim_win_set_cursor(window_id, cursor)
    end)
  end),
})

local default_word_opts = {
  char_pattern = [[\k]],
}
local to_word_opts = function(raw_opts)
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", default_word_opts, raw_opts)
end

function M.forward(raw_opts)
  local opts = to_word_opts(raw_opts)
  _original_cursor = vim.api.nvim_win_get_cursor(0)
  return require("searcho.core.search_target").forward_command(_original_cursor, opts.char_pattern)
end

function M.backward(raw_opts)
  local opts = to_word_opts(raw_opts)
  _original_cursor = vim.api.nvim_win_get_cursor(0)
  return require("searcho.core.search_target").backward_command(_original_cursor, opts.char_pattern)
end

function M.normal(cmd)
  require("searcho.core.search_highlight").disable_on_next_moved()
  return cmd
end

function M.setup_keymaps(keymap_func)
  local group = vim.api.nvim_create_augroup("searcho_keymap", {})
  local cleanup_keymaps = function() end

  vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
    group = group,
    pattern = { "*" },
    callback = for_search(function()
      local custom_vim, cleanup = require("searcho.lib.keymap").with_cleanup()
      cleanup_keymaps = cleanup
      keymap_func(custom_vim)
    end),
  })

  vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
    group = group,
    pattern = { "*" },
    callback = for_search(function()
      cleanup_keymaps()
    end),
  })
end

return M
