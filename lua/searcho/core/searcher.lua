local Origin = require("searcho.core.origin")
local SearchResultFactory = require("searcho.core.search_result_factory")
local SearchHighlight = require("searcho.core.search_highlight")
local SearchDirection = require("searcho.core.search_direction")
local SearchScroll = require("searcho.core.search_scroll")
local RowRange = require("searcho.core.row_range")
local CursorMovedCallback = require("searcho.core.cursor_moved_callback")
local BufferCursorMovedCallback = require("searcho.core.buffer_cursor_moved_callback")
local cursorlib = require("searcho.lib.cursor")
local vim = vim

local Searcher = {}
Searcher.__index = Searcher

function Searcher.new(window_id, is_forward, accepted_cursor_position, adjust_pos)
  vim.validate({
    window_id = { window_id, "number" },
    is_forward = { is_forward, "boolean" },
    accepted_cursor_position = { accepted_cursor_position, "boolean" },
    adjust_pos = { adjust_pos, "table", true },
  })

  local cursor_moved_callback = CursorMovedCallback.new()
  cursor_moved_callback:disable()

  local origin = Origin.new(window_id)
  local tbl = {
    _window_id = window_id,
    _highlight = SearchHighlight.new(window_id),
    _origin = origin,
    _adjust_pos = adjust_pos or origin.position,
    _search_direction = SearchDirection.new(is_forward),
    _search_scroll = SearchScroll.new(window_id, 1000),
    _result_factory = SearchResultFactory.new(window_id, is_forward, accepted_cursor_position),
    _result = SearchResultFactory.none(),
    _input = "",
    _cursor_moved_callback = cursor_moved_callback,
  }
  return setmetatable(tbl, Searcher)
end

function Searcher.forward(window_id)
  local is_forward = true
  local accepted_cursor_position = false
  return Searcher.new(window_id, is_forward, accepted_cursor_position)
end

function Searcher.forward_word(window_id)
  local is_forward = true
  local accepted_cursor_position = true
  local word_head_pos = cursorlib.word_head_position(window_id)
  local adjust_pos = cursorlib.get_left(window_id, unpack(word_head_pos))
  return Searcher.new(window_id, is_forward, accepted_cursor_position, adjust_pos)
end

function Searcher.backward(window_id)
  local is_forward = false
  local accepted_cursor_position = false
  return Searcher.new(window_id, is_forward, accepted_cursor_position)
end

function Searcher.backward_word(window_id)
  local is_forward = false
  local accepted_cursor_position = true
  local adjust_pos = cursorlib.word_tail_position(window_id)
  return Searcher.new(window_id, is_forward, accepted_cursor_position, adjust_pos)
end

function Searcher.execute(self, input)
  self._input = input

  self._search_direction:set()
  vim.api.nvim_win_set_cursor(self._window_id, self._adjust_pos)
  self._highlight:reset()

  local result = self._result_factory:create(input)
  return self:_update(result)
end

function Searcher.next_match(self)
  if not self._result.matched then
    return
  end
  self._cursor_moved_callback:setup()

  local row, col = unpack(self._result.matched_end)
  local result = self._result_factory:match(row, col, "n", "N", self._input)
  return self:_update(result)
end

function Searcher.previous_match(self)
  if not self._result.matched then
    return
  end
  self._cursor_moved_callback:setup()

  local row, col = unpack(self._result.matched_start)
  local result = self._result_factory:match(row, col, "2N", "n", self._input)
  return self:_update(result)
end

function Searcher.next_page(self)
  if not self._result.matched then
    return
  end
  self._cursor_moved_callback:setup()

  local row, col = unpack({ cursorlib.next_page_row(self._window_id), 0 })
  local result = self._result_factory:match(row, col, "n", "2N", self._input)
  return self:_update(result)
end

function Searcher.previous_page(self)
  if not self._result.matched then
    return
  end
  self._cursor_moved_callback:setup()

  local row, col = unpack({ cursorlib.previous_page_row(self._window_id), 0 })
  local result = self._result_factory:match(row, col, "N", "2n", self._input)
  return self:_update(result)
end

function Searcher.finish(self, callback)
  -- HACK: for stopinsert on last char
  local last_col = vim.api.nvim_win_call(self._window_id, function()
    return vim.fn.col("$") - 1
  end)
  if self._result:is_last_char(last_col) then
    cursorlib.add_column(self._window_id)
  end

  self._highlight:reset_current_match()
  self._search_direction:set()
  cursorlib.add_to_jumplist(self._window_id, self._origin.position)
  self._origin:restore_scrolloff()

  self._cursor_moved_callback:setup()

  local bufnr = vim.api.nvim_win_get_buf(self._window_id)
  local buffer_cursor_moved_callback = BufferCursorMovedCallback.new(bufnr, callback)
  buffer_cursor_moved_callback:setup()

  return self._result.err
end

function Searcher.cancel(self)
  self._highlight:reset()
  self._origin:restore()
end

function Searcher._update(self, result)
  self._result = result
  if not result.matched then
    return
  end
  local start_row, start_col = unpack(self._result.matched_start)
  local end_row, end_col = unpack(self._result.matched_end)

  self:_centering_if_need(start_row)
  self._highlight:enable(self._input, start_row, start_col, end_row, end_col)

  vim.api.nvim_win_set_cursor(self._window_id, { start_row, start_col })
end

function Searcher._centering_if_need(self, row)
  if RowRange.current(self._window_id):include(row) then
    return self._origin:restore_scrolloff()
  end
  self._search_scroll:set()
end

function Searcher.next(window_id, callback)
  return Searcher._n_cmd(window_id, "n", callback)
end

function Searcher.previous(window_id, callback)
  return Searcher._n_cmd(window_id, "N", callback)
end

function Searcher._n_cmd(window_id, n, callback)
  local cursor_moved_callback = CursorMovedCallback.new()
  cursor_moved_callback:setup()

  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local buffer_cursor_moved_callback = BufferCursorMovedCallback.new(bufnr, callback)
  buffer_cursor_moved_callback:setup()

  local before_pos = vim.api.nvim_win_get_cursor(window_id)
  local ok, err = pcall(vim.cmd, "normal! " .. n)
  if not ok then
    return err
  end
  local after_pos = vim.api.nvim_win_get_cursor(window_id)
  if before_pos[1] == after_pos[1] and before_pos[2] == after_pos[2] then
    cursor_moved_callback:reset()
    buffer_cursor_moved_callback:reset()
  end
end

return Searcher
