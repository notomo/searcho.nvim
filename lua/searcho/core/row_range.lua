local M = {}

local RowRange = {}
RowRange.__index = RowRange
M.RowRange = RowRange

function RowRange.new(s, e)
  vim.validate({s = {s, "number"}, e = {e, "number"}})
  local tbl = {_s = s, _e = e}
  return setmetatable(tbl, RowRange)
end

function RowRange.current(window_id)
  vim.validate({window_id = {window_id, "number"}})

  local s, e
  vim.api.nvim_win_call(window_id, function()
    s = vim.fn.line("w0")
    e = vim.fn.line("w$")
  end)
  return RowRange.new(s, e)
end

function RowRange.include(self, row)
  return self._s <= row and row <= self._e
end

return M
