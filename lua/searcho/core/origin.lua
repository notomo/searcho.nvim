local SearchDirection = require("searcho.core.search_direction").SearchDirection
local SearchScroll = require("searcho.core.search_scroll").SearchScroll

local M = {}

local Origin = {}
Origin.__index = Origin
M.Origin = Origin

function Origin.new(window_id)
  vim.validate({window_id = {window_id, "number"}})

  local saved = vim.api.nvim_win_call(window_id, function()
    return vim.fn.winsaveview()
  end)
  local tbl = {
    position = vim.api.nvim_win_get_cursor(window_id),
    _window_id = window_id,
    _hlsearch = vim.v.hlsearch,
    _search_direction = SearchDirection.current(),
    _search_scroll = SearchScroll.current(window_id),
    _register = vim.fn.getreg("/"),
    _saved = saved,
  }
  return setmetatable(tbl, Origin)
end

function Origin.restore(self)
  vim.fn.setreg("/", self._register)
  self._search_direction:set()
  self:restore_scrolloff()
  vim.api.nvim_win_call(self._window_id, function()
    vim.fn.winrestview(self._saved)
  end)

  -- +1 for stopinsert
  vim.api.nvim_win_set_cursor(self._window_id, {self.position[1], self.position[2] + 1})
end

function Origin.restore_scrolloff(self)
  self._search_scroll:set()
end

return M
