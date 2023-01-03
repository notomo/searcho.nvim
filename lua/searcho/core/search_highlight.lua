local Decorator = require("searcho.lib.decorator")
local bufferlib = require("searcho.lib.buffer")

local SearchHighlight = {}
SearchHighlight.__index = SearchHighlight

function SearchHighlight.new(window_id)
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local tbl = {
    _decorator_factory = Decorator.factory("searcho", bufnr),
    _bufnr = bufnr,
  }
  return setmetatable(tbl, SearchHighlight)
end

function SearchHighlight.reset(self)
  vim.cmd.nohlsearch()
  self:reset_current_match()
end

function SearchHighlight.reset_current_match(self)
  return self._decorator_factory:reset()
end

function SearchHighlight.enable(self, input, start_row, start_col, end_row, end_col)
  self:_enable_match(input)
  self:_enable_current_match(start_row, start_col, end_row, end_col)
end

function SearchHighlight._enable_match(_, input)
  -- HACK
  if input == "\\v" then
    return
  end
  vim.cmd.let({ args = { "&hlsearch", "=", "&hlsearch" } })
end

function SearchHighlight._enable_current_match(self, start_row, start_col, end_row, end_col)
  local decorator = self:reset_current_match()
  local text = bufferlib.get_text(self._bufnr, start_row - 1, start_col, end_row - 1, end_col)
  local strs = vim.split(text, "\n", { plain = true })
  decorator:add_virtual_text_range(strs, "CurSearch", start_row - 1, start_col - 1, {
    virt_text_pos = "overlay",
  })
end

return SearchHighlight
