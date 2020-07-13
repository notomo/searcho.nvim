local search = require "searcho/search"

local M = {}

local cmds = {
  forward = function()
    return search.forward()
  end,
  backward = function()
    return search.backward()
  end,
  adjust = function(input)
    return search.adjust(input)
  end,
  next = function()
    return search.next()
  end,
  prev = function()
    return search.prev()
  end,
  next_page = function()
    return search.next_page()
  end,
  prev_page = function()
    return search.prev_page()
  end
}

M.main = function(...)
  local args = {...}

  local name = args[1]
  if name == nil then
    name = "forward"
  end

  local cmd = cmds[name]
  if cmd == nil then
    return vim.api.nvim_err_write("not found command: args=" .. vim.inspect(args) .. "\n")
  end

  local cmd_args = {unpack(args, 2)}
  local f = function()
    return cmd(unpack(cmd_args))
  end
  local ok, result = xpcall(f, debug.traceback)
  if not ok then
    error(result)
  end
  return result
end

return M
