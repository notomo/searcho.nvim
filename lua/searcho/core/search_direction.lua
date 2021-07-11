local M = {}

local SearchDirection = {}
SearchDirection.__index = SearchDirection
M.SearchDirection = SearchDirection

function SearchDirection.new(is_forward)
  vim.validate({is_forward = {is_forward, "boolean"}})

  local searchforward
  if is_forward then
    searchforward = 1
  else
    searchforward = 0
  end

  local tbl = {_searchforward = searchforward}
  return setmetatable(tbl, SearchDirection)
end

function SearchDirection.current()
  return SearchDirection.new(vim.v.searchforward == 1)
end

function SearchDirection.is_forward(self)
  return self._searchforward == 1
end

function SearchDirection.set(self)
  vim.cmd("let v:searchforward = " .. self._searchforward)
end

return M
