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

function M.word_forward()
  _original_cursor = vim.api.nvim_win_get_cursor(0)

  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    require("searcho.lib.view").with_restore(function()
      vim.cmd.normal({ args = { "*Nh" }, bang = true, mods = { keepjumps = true } })
    end)
  end

  local search_command = "/"
  local cursor = vim.api.nvim_win_get_cursor(0)
  if cursor[1] == 1 and cursor[2] == 0 then
    search_command = search_command .. vim.keycode("<C-t>")
  end

  vim.api.nvim_feedkeys(search_command .. word, "t", true)
end

function M.word_backward()
  _original_cursor = vim.api.nvim_win_get_cursor(0)

  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    require("searcho.lib.view").with_restore(function()
      vim.cmd.normal({ args = { "#Ne" }, bang = true, mods = { keepjumps = true } })
    end)
  end

  local search_command = "?"
  vim.api.nvim_feedkeys(search_command .. word, "t", true)
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
