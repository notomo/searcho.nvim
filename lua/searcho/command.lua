local M = {}

local for_search = require("searcho.lib.autocmd").for_search

local _original_cursor
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
  group = vim.api.nvim_create_augroup("searcho", {}),
  pattern = { "*" },
  callback = for_search(function()
    if not vim.v.event.abort then
      require("searcho.core.search_highlight").disable_on_next_moved()
      return
    end

    require("searcho.core.search_highlight").disable()

    local window_id = vim.api.nvim_get_current_win()
    if _original_cursor then
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(window_id, _original_cursor)
        _original_cursor = nil
      end)
    end
  end),
})

local default_word_opts = {
  convert = function(word)
    return word
  end,
}
local to_word_opts = function(raw_opts)
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", default_word_opts, raw_opts)
end

function M.word_forward(raw_opts)
  local opts = to_word_opts(raw_opts)

  _original_cursor = vim.api.nvim_win_get_cursor(0)

  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    require("searcho.lib.view").with_restore(function()
      vim.cmd.normal({ args = { "*Nh" }, bang = true, mods = { keepjumps = true } })

      local cursor = vim.api.nvim_win_get_cursor(0)
      if cursor[1] == 1 and cursor[2] == 0 then
        vim.cmd.normal({ args = { "G$" }, bang = true, mods = { keepjumps = true } })
      end
    end)
  end

  vim.api.nvim_feedkeys("/" .. opts.convert(word), "t", true)
end

function M.word_backward(raw_opts)
  local opts = to_word_opts(raw_opts)

  _original_cursor = vim.api.nvim_win_get_cursor(0)

  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    require("searcho.lib.view").with_restore(function()
      vim.cmd.normal({ args = { "#Ne" }, bang = true, mods = { keepjumps = true } })

      local last_row = vim.api.nvim_buf_line_count(0)
      if _original_cursor[1] == last_row and _original_cursor[2] == vim.fn.col("$") - 2 then
        vim.cmd.normal({ args = { "gg0" }, bang = true, mods = { keepjumps = true } })
      end
    end)
  end

  vim.api.nvim_feedkeys("?" .. opts.convert(word), "t", true)
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
