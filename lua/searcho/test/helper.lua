local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

function helper.before_each()
  -- to suppress search messages in test output
  vim.opt.shortmess:append("S")
  vim.opt.shortmess:append("s")
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.cursor_moved()
  vim.api.nvim_exec_autocmds("CursorMoved", {})
end

function helper.execute_as_expr(fn)
  local key = "n"
  vim.keymap.set("n", key, fn, { buffer = true, expr = true })
  vim.api.nvim_feedkeys(key, "tx", true)
end

local asserts = require("vusted.assert").asserts
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

return helper
