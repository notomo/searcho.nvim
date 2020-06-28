local M = {}

M.root = vim.fn.getcwd()

M.command = function(cmd)
  vim.api.nvim_command(cmd)
end

M.before_each = function()
  M.command("filetype on")
  M.command("syntax enable")
end

M.after_each = function()
  M.command("tabedit")
  M.command("tabonly!")
  M.command("silent! %bwipeout!")
  M.command("filetype off")
  M.command("syntax off")
  print(" ")

  -- NOTE: for require("test.helper")
  vim.api.nvim_set_current_dir(M.root)

  require("searcho/cleanup")("searcho")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.input_key = function(key)
  M.command("normal " .. key)
end

local assert = require("luassert")
local AM = {}

AM.current_line = function(expected)
  local actual = vim.fn.getline(".")
  local msg = ("current line should be %s, but actual: %s"):format(expected, actual)
  assert.equals(expected, actual, msg)
end

AM.has_keymap = function(lhs, rhs)
  local keymaps = vim.api.nvim_buf_get_keymap(0, "c")
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == lhs and keymap.rhs == rhs then
      return
    end
  end
  assert(false, ("no keymap: lhs=%s rhs=%s"):format(lhs, rhs))
end

M.assert = AM

return M
