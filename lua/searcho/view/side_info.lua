local Decorator = require("searcho.lib.decorator")

local SideInfo = {}
SideInfo.__index = SideInfo

function SideInfo.new(window_id)
  vim.validate({ window_id = { window_id, "number" } })
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local tbl = {
    _decorator_factory = Decorator.factory("searcho_side_info", bufnr),
    _window_id = window_id,
  }
  return setmetatable(tbl, SideInfo)
end

function SideInfo.show(self, msg)
  local decorator = self._decorator_factory:reset()
  if msg == "[0/0]" then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(self._window_id)
  decorator:add_virtual_text(cursor[1] - 1, 0, { { (" %s "):format(msg), "Comment" } }, {})
end

function SideInfo.clear(self)
  self._decorator_factory:reset()
end

return SideInfo
