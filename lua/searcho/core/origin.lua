local M = {}

local Origin = {}
Origin.__index = Origin
M.Origin = Origin

function Origin.new(window_id)
  vim.validate({window_id = {window_id, "number"}})

  local scrolloff = vim.api.nvim_win_call(window_id, function()
    return tonumber(vim.api.nvim_exec("silent! echo &scrolloff", true))
  end)

  local first_row, last_row
  vim.api.nvim_win_call(window_id, function()
    first_row = vim.fn.line("w0")
    last_row = vim.fn.line("w$")
  end)

  local tbl = {
    position = vim.api.nvim_win_get_cursor(window_id),
    _window_id = window_id,
    _scrolloff = scrolloff,
    _hlsearch = vim.v.hlsearch,
    _searchforward = vim.v.searchforward,
    _register = vim.fn.getreg("/"),
    _first_row = first_row,
    _last_row = last_row,
  }
  return setmetatable(tbl, Origin)
end

function Origin.in_range(self, row)
  return self._first_row <= row and row <= self._last_row
end

function Origin.restore(self)
  vim.fn.setreg("/", self._register)
  vim.cmd("let v:searchforward = " .. self._searchforward)
  self:restore_scrolloff()

  -- +1 for stopinsert
  vim.api.nvim_win_set_cursor(self._window_id, {self.position[1], self.position[2] + 1})
end

function Origin.restore_scrolloff(self)
  vim.api.nvim_win_call(self._window_id, function()
    vim.cmd("silent! noautocmd setlocal scrolloff=" .. tostring(self._scrolloff))
  end)
end

return M
