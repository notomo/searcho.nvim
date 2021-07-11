local SearchDirection = require("searcho.core.search_direction").SearchDirection
local cursorlib = require("searcho.lib.cursor")

local M = {}

local SearchResultFactory = {}
SearchResultFactory.__index = SearchResultFactory
M.SearchResultFactory = SearchResultFactory

function SearchResultFactory.new(window_id, is_forward, accepted_cursor_position)
  local flag = "nz"
  if not is_forward then
    flag = flag .. "b"
  end
  if accepted_cursor_position then
    flag = flag .. "c"
  end
  local end_match_flag = "e" .. flag:gsub("b", "")

  local tbl = {_window_id = window_id, _flag = flag, _end_match_flag = end_match_flag}
  return setmetatable(tbl, SearchResultFactory)
end

local SearchResult = {}
SearchResult.__index = SearchResult
M.SearchResult = SearchResult

function SearchResult.new(s, e, err)
  vim.validate({s = {s, "table", true}, e = {e, "table", true}, err = {err, "string", true}})
  local tbl = {matched_start = s, matched_end = e, err = err, matched = s and e}
  return setmetatable(tbl, SearchResult)
end

function SearchResult.none()
  return SearchResult.new(nil, nil, nil)
end

function SearchResult.error(err)
  return SearchResult.new(nil, nil, err)
end

function SearchResultFactory.create(self, input)
  if input == "" then
    vim.fn.setreg("/", input)
    return SearchResult.none()
  end

  local ok, result
  vim.api.nvim_win_call(self._window_id, function()
    ok, result = pcall(vim.fn.searchpos, input, self._flag)
  end)

  if not ok then
    return SearchResult.error(result)
  end

  local row, col = unpack(result)
  if row == 0 then
    return SearchResult.none()
  end
  vim.fn.setreg("/", input)

  local s = {row, col}
  local e = self:_matched_end(row, col, input)
  return SearchResult.new(s, e)
end

function SearchResultFactory.match(self, row, col, next_cmd, prev_cmd, input)
  vim.api.nvim_win_set_cursor(self._window_id, {row, col})

  vim.api.nvim_win_call(self._window_id, function()
    if SearchDirection.current():is_forward() then
      return vim.cmd("silent! noautocmd keepjumps normal! " .. next_cmd)
    end
    vim.cmd("silent! noautocmd keepjumps normal! " .. prev_cmd)
  end)

  local start_row, start_col = unpack(vim.api.nvim_win_get_cursor(self._window_id))
  start_col = start_col + 1
  vim.api.nvim_win_set_cursor(self._window_id, {row, col})

  local s = {start_row, start_col}
  local e = self:_matched_end(start_row, start_col, input)
  return SearchResult.new(s, e)
end

function SearchResultFactory._matched_end(self, row, col, input)
  cursorlib.left(self._window_id, row, col - 1) -- HACK: for `e` flag
  local end_row, end_col = unpack(vim.api.nvim_win_call(self._window_id, function()
    return vim.fn.searchpos(input, self._end_match_flag)
  end))
  if input == "\\v" then -- HACK
    end_col = math.max(end_col - 1, 1)
  end
  return {end_row, end_col}
end

return M
