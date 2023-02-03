local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each() end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.input(str)
  local texts = vim.split(str, "\n", { plain = true })
  vim.api.nvim_put(texts, "", false, true)
end

function helper.cursor_moved()
  vim.api.nvim_exec_autocmds("CursorMoved", {})
end

local asserts = require("vusted.assert").asserts
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

return helper
