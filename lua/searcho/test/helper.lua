local helper = require("ntf.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.api.nvim_set_option_value(
  "packpath",
  vim.env.TESTPACK_PACKPATH or vim.fs.joinpath(helper.root, "spec/.shared/packages"),
  { operation = "prepend" }
)
require("assertlib").register(require("ntf.assert").register)

function helper.before_each()
  -- to suppress search messages in test output
  vim.api.nvim_set_option_value("shortmess", "S", { operation = "append" })
  vim.api.nvim_set_option_value("shortmess", "s", { operation = "append" })
end

function helper.after_each() end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.cursor_moved()
  vim.api.nvim_exec_autocmds("CursorMoved", {})
end

function helper.execute_as_expr(fn)
  local key = "n"
  vim.keymap.set("n", key, fn, { buf = 0, expr = true })
  vim.api.nvim_feedkeys(key, "tx", true)
end

return helper
