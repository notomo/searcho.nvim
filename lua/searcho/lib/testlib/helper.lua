local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each() end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  print(" ")
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.input(str)
  local texts = vim.split(str, "\n", true)
  vim.api.nvim_put(texts, "", false, true)
end

function helper.cursor_moved()
  vim.api.nvim_exec_autocmds("CursorMoved", {})
end

local asserts = require("vusted.assert").asserts

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("buffer_name"):register_eq(function()
  return vim.fn.bufname("%")
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

return helper
