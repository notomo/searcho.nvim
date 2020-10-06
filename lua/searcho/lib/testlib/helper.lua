local M = {}

local root, err = require("searcho/lib/path").find_root("searcho.nvim")
if err ~= nil then
  error(err)
end
M.root = root

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

  vim.api.nvim_set_current_dir(M.root)

  require("searcho/cleanup")("searcho")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.input_key = function(key)
  M.command("normal " .. key)
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("has_keymap"):register(function(self)
  return function(_, args)
    local lhs = args[1]
    local rhs = args[2]
    self:set_positive(("not found keymap lhs=%s rhs=%s"):format(lhs, rhs))
    self:set_negative(("found keymap lhs=%s rhs=%s"):format(lhs, rhs))
    local keymaps = vim.api.nvim_buf_get_keymap(0, "c")
    for _, keymap in ipairs(keymaps) do
      if keymap.lhs == lhs and keymap.rhs == rhs then
        return true
      end
    end
    return false
  end
end)

return M
