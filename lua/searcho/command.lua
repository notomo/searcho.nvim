local View = require("searcho.view").View
local messagelib = require("searcho.lib.message")

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, msg = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(msg)
  elseif msg then
    return messagelib.vim_warn(msg)
  end
end

function Command.search(method_name, input)
  return View.open_searcher(method_name, input)
end

function Command.search_word(method_name, opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}
  return View.open_word_searcher(method_name, opts.left, opts.right)
end

function Command.move_cursor(method_name)
  local view = View.current()
  if not view then
    return "no state"
  end
  return view:move_cursor(method_name)
end

function Command.move_cursor_in_normal(method_name)
  local msg, err = View.move_cursor_in_normal(method_name)
  if err then
    return err
  end
  return messagelib.raw_info(msg)
end

function Command.finish()
  local view = View.current()
  if not view then
    return "no state"
  end
  local msg, err = view:finish()
  if err then
    return err
  end
  return messagelib.raw_info(msg)
end

function Command.cancel()
  local view = View.current()
  if not view then
    return
  end
  return view:cancel()
end

function Command.recall_history(offset)
  vim.validate({offset = {offset, "number"}})
  local view = View.current()
  if not view then
    return "no state"
  end
  view:recall_history(offset)
end

function Command.close(id)
  vim.validate({id = {id, "number"}})
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return M
