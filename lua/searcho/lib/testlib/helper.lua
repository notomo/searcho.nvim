local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local M = require("vusted.helper")

M.root = M.find_plugin_root(plugin_name)

function M.before_each()
  vim.o.lines = 24
  vim.o.columns = 80
  vim.o.display = "lastline,msgsep" -- workaround for crash
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
end

function M.after_each()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent! %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
  vim.cmd("messages clear")
  vim.fn.setreg("/", "")
  vim.fn.histdel("/", "^\\*")
  print(" ")

  vim.api.nvim_set_current_dir(M.root)

  M.cleanup_loaded_modules(plugin_name)
end

function M.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function M.input(str)
  local texts = vim.split(str, "\n", true)
  vim.api.nvim_put(texts, "", false, true)
end

function M.cursor_moved()
  vim.cmd("doautocmd CursorMoved")
end

local asserts = require("vusted.assert").asserts

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("cursor_word"):register_eq(function()
  return vim.fn.expand("<cword>")
end)

asserts.create("exists_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("`%s` not found message"):format(expected))
    self:set_negative(("`%s` found message"):format(expected))
    local messages = vim.split(vim.api.nvim_exec("messages", true), "\n")
    for _, msg in ipairs(messages) do
      if msg:find(expected, 1, true) then
        return true
      end
    end
    return false
  end
end)

return M
