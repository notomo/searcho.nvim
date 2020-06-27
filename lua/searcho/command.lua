local search = require "searcho/search"

local M = {}

local cmds = {
  forward = function()
    return search.forward()
  end,
  backward = function()
    return search.backward()
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

  return cmd()
end

return M
