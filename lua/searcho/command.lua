local View = require("searcho.view")
local messagelib = require("searcho.lib.message")

local M = {}

function M.search(method_name, input)
  View.open_searcher(method_name, input)
end

function M.search_word(method_name, opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}
  View.open_word_searcher(method_name, opts.left, opts.right)
end

function M.move_cursor(method_name)
  local view = View.current()
  if not view then
    messagelib.error("no state")
  end
  view:move_cursor(method_name)
end

function M.move_cursor_in_normal(method_name, opts)
  opts = opts or {}

  local msg, err = View.move_cursor_in_normal(method_name)
  if err then
    messagelib.warn(err)
    return
  end
  messagelib.raw_info(msg, opts.add_to_history)
end

function M.finish(opts)
  opts = opts or {}

  local view = View.current()
  if not view then
    messagelib.error("no state")
  end
  local msg, err = view:finish()
  if err then
    messagelib.warn(err)
    return
  end
  messagelib.raw_info(msg, opts.add_to_history)
end

function M.cancel()
  local view = View.current()
  if not view then
    return
  end
  view:cancel()
end

function M.recall_history(offset)
  vim.validate({ offset = { offset, "number" } })
  local view = View.current()
  if not view then
    messagelib.error("no state")
  end
  view:recall_history(offset)
end

function M.close(id)
  vim.validate({ id = { id, "number" } })
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return M
