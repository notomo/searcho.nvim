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
    return vim.api.nvim_get_option_value("scrolloff", {scope = "local"})
  end)
  return SearchScroll.new(window_id, scrolloff)
end

function SearchScroll.set(self)
  vim.api.nvim_win_call(self._window_id, function()
    vim.api.nvim_set_option_value("scrolloff", self._scrolloff, {scope = "local"})
  end)
end

return M
