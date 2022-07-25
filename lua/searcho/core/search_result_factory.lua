local SearchDirection = require("searcho.core.search_direction")
local cursorlib = require("searcho.lib.cursor")

local SearchResultFactory = {}
SearchResultFactory.__index = SearchResultFactory

local SearchResult = {}
SearchResult.__index = SearchResult

function SearchResultFactory.new(window_id, is_forward, accepted_cursor_position)
  local flag = "nz"
  if not is_forward then
    flag = flag .. "b"
  end
  if accepted_cursor_position then
    flag = flag .. "c"
  end
  local end_match_flag = "e" .. flag:gsub("b", "")

  local tbl = { _window_id = window_id, _is_forward = is_forward, _end_match_flag = end_match_flag }
  return setmetatable(tbl, SearchResultFactory)
end

function SearchResultFactory.none()
  return SearchResult.new(nil, nil, nil)
end

function SearchResult.new(s, e, err)
  vim.validate({ s = { s, "table", true }, e = { e, "table", true }, err = { err, "string", true } })
  local tbl = { matched_start = s, matched_end = e, err = err, matched = (s and e) ~= nil }
  return setmetatable(tbl, SearchResult)
end

function SearchResult.none()
  return SearchResult.new(nil, nil, nil)
end

function SearchResult.error(err)
  return SearchResult.new(nil, nil, err)
end

function SearchResult.is_last_char(self, last_col)
  if not self.matched then
    return false
  end
  if not (self.matched_start[1] == self.matched_end[1] and self.matched_start[2] == self.matched_end[2]) then
    return false
  end
  return last_col == self.matched_end[2]
end

function SearchResultFactory.create(self, input)
  if input == "" then
    vim.fn.setreg("/", input)
    return SearchResult.none()
  end

  local row, col, err = self:_search(input)
  if err then
    return SearchResult.error(err)
  end
  vim.fn.setreg("/", input)

  local s = { row, col }
  local e = self:_matched_end(row, col, input)
  return SearchResult.new(s, e)
end

local CR = vim.api.nvim_eval([["\<CR>"]])
function SearchResultFactory._search(self, input)
  local origin_row, origin_col = unpack(vim.api.nvim_win_get_cursor(self._window_id))

  local search = "/"
  if not self._is_forward then
    search = "?"
  end
  local ok, err
  vim.api.nvim_win_call(self._window_id, function()
    local cmd = ("silent noautocmd keepjumps normal! %s%s%s"):format(search, vim.fn.escape(input, "/"), CR)
    ok, err = pcall(vim.cmd, cmd)
  end)
  if not ok then
    return nil, nil, err
  end
  vim.fn.histdel("search", -1)
  vim.cmd.nohlsearch()

  local row, column = unpack(vim.api.nvim_win_get_cursor(self._window_id))
  if input == "\\v\\n" or input == "\\n" then
    -- HACK
    column = column + 1
  end
  vim.api.nvim_win_set_cursor(self._window_id, { origin_row, origin_col })
  return row, column + 1, nil
end

function SearchResultFactory.match(self, row, col, next_cmd, prev_cmd, input)
  local origin_row, origin_col = unpack(vim.api.nvim_win_get_cursor(self._window_id))

  vim.api.nvim_win_set_cursor(self._window_id, { row, col })

  vim.api.nvim_win_call(self._window_id, function()
    if SearchDirection.current():is_forward() then
      return vim.cmd.normal({
        args = { next_cmd },
        mods = { silent = true, emsg_silent = true, noautocmd = true, keepjumps = true },
        bang = true,
      })
    end
    vim.cmd.normal({
      args = { prev_cmd },
      mods = { silent = true, emsg_silent = true, noautocmd = true, keepjumps = true },
      bang = true,
    })
  end)

  local start_row, start_col = unpack(vim.api.nvim_win_get_cursor(self._window_id))
  start_col = start_col + 1
  vim.api.nvim_win_set_cursor(self._window_id, { row, col })

  local s = { start_row, start_col }
  if input == "\\v\\n" or input == "\\n" then
    -- HACK
    s[1] = s[1] + 1
  end
  local e = self:_matched_end(start_row, start_col, input)
  vim.api.nvim_win_set_cursor(self._window_id, { origin_row, origin_col })
  return SearchResult.new(s, e)
end

function SearchResultFactory._matched_end(self, row, col, input)
  local origin_row, origin_col = unpack(vim.api.nvim_win_get_cursor(self._window_id))
  cursorlib.left(self._window_id, row, col - 1) -- HACK: for `e` flag
  if input == "\\v" then
    input = "\\v."
  end
  local end_row, end_col = unpack(vim.api.nvim_win_call(self._window_id, function()
    return vim.fn.searchpos(input, self._end_match_flag)
  end))
  vim.api.nvim_win_set_cursor(self._window_id, { origin_row, origin_col })
  return { end_row, end_col }
end

return SearchResultFactory
