local Decorator = require("searcho.lib.decorator")
local vim = vim

local Info = {}
Info.__index = Info

function Info.new(bufnr, window_id)
  vim.validate({ bufnr = { bufnr, "number" }, window_id = { window_id, "number" } })
  local tbl = {
    _window_id = window_id,
    _decorator_factory = Decorator.factory("searcho", bufnr),
  }
  return setmetatable(tbl, Info)
end

function Info.show(self)
  local decorator = self._decorator_factory:reset()
  local msg = vim.api.nvim_win_call(self._window_id, function()
    return self:_count()
  end)
  decorator:add_virtual_text(0, 0, { { msg, "Comment" } }, {})
  return msg
end

function Info._count()
  local ok, count = pcall(vim.fn.searchcount)
  if not ok or vim.tbl_isempty(count) then
    return "[0/0]"
  end

  if count.incomplete == 1 then
    return "[?/??]"
  elseif count.incomplete == 0 then
    return ("[%d/%d]"):format(count.current, count.total)
  end
  -- count.incomplete == 2
  if count.total > count.maxcount and count.current > count.maxcount then
    return ("[>%d/>%d]"):format(count.current, count.total)
  elseif count.total > count.maxcount then
    return ("[%d/>%d]"):format(count.current, count.total)
  end

  return "[0/0]"
end

function Info.msg()
  local prefix
  if vim.v.searchforward == 1 then
    prefix = "/"
  else
    prefix = "?"
  end
  local count_msg = Info._count()
  return ("%s%s %s"):format(prefix, vim.fn.getreg("/"), count_msg), count_msg
end

return Info
