local View = require("searcho.view")
local messagelib = require("searcho.lib.message")

local ShowAsUserError = require("searcho.vendor.misclib.error_handler").for_show_as_user_error()
local ShowError = require("searcho.vendor.misclib.error_handler").for_show_error()

function ShowAsUserError.search(method_name, input)
  return View.open_searcher(method_name, input)
end

function ShowAsUserError.search_word(method_name, opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}
  return View.open_word_searcher(method_name, opts.left, opts.right)
end

function ShowError.move_cursor(method_name)
  local view = View.current()
  if not view then
    return "no state"
  end
  return view:move_cursor(method_name)
end

function ShowAsUserError.move_cursor_in_normal(method_name, opts)
  opts = opts or {}

  local msg, err = View.move_cursor_in_normal(method_name)
  if err then
    return err
  end
  return messagelib.raw_info(msg, opts.add_to_history)
end

function ShowError.finish(opts)
  opts = opts or {}

  local view = View.current()
  if not view then
    return "no state"
  end
  local msg, err = view:finish()
  if err then
    return err
  end
  return messagelib.raw_info(msg, opts.add_to_history)
end

function ShowError.cancel()
  local view = View.current()
  if not view then
    return
  end
  return view:cancel()
end

function ShowError.recall_history(offset)
  vim.validate({ offset = { offset, "number" } })
  local view = View.current()
  if not view then
    return "no state"
  end
  view:recall_history(offset)
end

function ShowError.close(id)
  vim.validate({ id = { id, "number" } })
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return vim.tbl_extend("force", ShowAsUserError:methods(), ShowError:methods())
