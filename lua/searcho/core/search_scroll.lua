local M = {}

local SearchScroll = {}
SearchScroll.__index = SearchScroll
M.SearchScroll = SearchScroll

function SearchScroll.new(window_id, scrolloff)
  vim.validate({window_id = {window_id, "number"}, scrolloff = {scrolloff, "number"}})
  local tbl = {_window_id = window_id, _scrolloff = scrolloff}
  return setmetatable(tbl, SearchScroll)
end

function SearchScroll.current(window_id)
  local scrolloff = vim.api.nvim_win_call(window_id, function()
    return tonumber(vim.api.nvim_exec("silent! echo &scrolloff", true))
  end)
  return SearchScroll.new(window_id, scrolloff)
end

function SearchScroll.set(self)
  vim.api.nvim_win_call(self._window_id, function()
    vim.cmd("silent! noautocmd setlocal scrolloff=" .. tostring(self._scrolloff))
  end)
end

return M
