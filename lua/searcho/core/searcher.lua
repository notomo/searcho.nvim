local HighlighterFactory = require("searcho.lib.highlight").HighlighterFactory
local Origin = require("searcho.core.origin").Origin
local SearchResultFactory = require("searcho.core.search_result").SearchResultFactory
local SearchResult = require("searcho.core.search_result").SearchResult
local on_moved = require("searcho.core.on_moved")
local bufferlib = require("searcho.lib.buffer")
local cursorlib = require("searcho.lib.cursor")
local vim = vim

local M = {}

local Searcher = {}
Searcher.__index = Searcher
M.Searcher = Searcher

function Searcher.new(window_id, is_forward, accepted_cursor_position, adjust_pos)
  vim.validate({
    window_id = {window_id, "number"},
    is_forward = {is_forward, "boolean"},
    accepted_cursor_position = {accepted_cursor_position, "boolean"},
    adjust_pos = {adjust_pos, "table", true},
  })

  local searchforward
  if is_forward then
    searchforward = 1
  else
    searchforward = 0
  end

  on_moved.disable()

  local origin = Origin.new(window_id)
  local result_factory = SearchResultFactory.new(window_id, is_forward, accepted_cursor_position)
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local tbl = {
    _window_id = window_id,
    _hl_factory = HighlighterFactory.new("searcho", bufnr),
    _origin = origin,
    _bufnr = bufnr,
    _adjust_pos = adjust_pos or origin.position,
    _searchforward = searchforward,
    _result_factory = result_factory,
    _result = SearchResult.none(),
    _input = "",
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
  local adjust_pos = cursorlib.word_head_position(window_id)
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
  local adjust_pos = cursorlib.word_head_position(window_id)
  return Searcher.new(window_id, is_forward, accepted_cursor_position, adjust_pos)
end

function Searcher.search(self, input)
  self._input = input
  vim.cmd("let v:searchforward = " .. self._searchforward)

  self:_restore()
  local result = self._result_factory:create(input)
  return self:_update(result)
end

function Searcher.next_match(self)
  if not self._result.matched then
    return
  end
  on_moved.setup()

  local row, col = unpack(self._result.matched_end)
  local result = self._result_factory:match(row, col, "n", "N", self._input)
  return self:_update(result)
end

function Searcher.previous_match(self)
  if not self._result.matched then
    return
  end
  on_moved.setup()

  local row, col = unpack(self._result.matched_start)
  local result = self._result_factory:match(row, col, "2N", "n", self._input)
  return self:_update(result)
end

function Searcher.next_page(self)
  if not self._result.matched then
    return
  end
  on_moved.setup()

  local row, col = unpack({cursorlib.next_page_row(self._window_id), 0})
  local result = self._result_factory:match(row, col, "n", "2N", self._input)
  return self:_update(result)
end

function Searcher.previous_page(self)
  if not self._result.matched then
    return
  end
  on_moved.setup()

  local row, col = unpack({cursorlib.previous_page_row(self._window_id), 0})
  local result = self._result_factory:match(row, col, "N", "2n", self._input)
  return self:_update(result)
end

function Searcher.finish(self)
  self._hl_factory:reset()
  vim.cmd("let v:searchforward = " .. self._searchforward)
  self._origin:restore_scrolloff()
  on_moved.setup()
  return self._result.err
end

function Searcher.cancel(self)
  vim.cmd("nohlsearch")
  self._hl_factory:reset()
  self._origin:restore()
end

function Searcher._update(self, result)
  self._result = result
  if not result.matched then
    return
  end
  self:_move_match()
end

function Searcher._move_match(self)
  local start_row, start_col = unpack(self._result.matched_start)
  local end_row, end_col = unpack(self._result.matched_end)

  self:_centering_if_need(start_row)

  self:_highlight(self._input)
  self:_highlight_current(start_row, start_col, end_row, end_col)

  vim.api.nvim_win_set_cursor(self._window_id, {start_row, start_col})
end

function Searcher._highlight(_, input)
  -- HACK
  if input == "\\v" then
    return
  end
  vim.cmd("let &hlsearch = &hlsearch")
end

function Searcher._highlight_current(self, start_row, start_col, end_row, end_col)
  local highlighter = self._hl_factory:reset()
  local text = bufferlib.get_text(self._bufnr, start_row - 1, start_col, end_row - 1, end_col)
  local strs = vim.split(text, "\n", true)
  highlighter:add_ranged_virtual(strs, "IncSearch", start_row - 1, start_col - 1, end_row - 1, end_col - 1, {
    virt_text_pos = "overlay",
  })
end

function Searcher._centering_if_need(self, row)
  if self._origin:in_range(row) then
    return
  end
  vim.api.nvim_win_call(self._window_id, function()
    vim.cmd("silent! noautocmd setlocal scrolloff=1000")
  end)
end

function Searcher._restore(self)
  vim.api.nvim_win_set_cursor(self._window_id, self._adjust_pos)
  vim.cmd("nohlsearch")
  self._hl_factory:reset()
end

function Searcher.next()
  return Searcher._n_cmd("n")
end

function Searcher.previous()
  return Searcher._n_cmd("N")
end

function Searcher._n_cmd(n)
  on_moved.setup()
  local before_pos = vim.api.nvim_win_get_cursor(0)
  local ok, err = pcall(vim.cmd, "normal! " .. n)
  if not ok then
    return err
  end
  local after_pos = vim.api.nvim_win_get_cursor(0)
  if before_pos[1] == after_pos[1] and before_pos[2] == after_pos[2] then
    on_moved.reset()
  end
end

return M
