local HighlighterFactory = require("searcho.lib.highlight").HighlighterFactory

local M = {}

local SideInfo = {}
SideInfo.__index = SideInfo
M.SideInfo = SideInfo

function SideInfo.new(window_id)
  vim.validate({window_id = {window_id, "number"}})
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local tbl = {
    _hl_factory = HighlighterFactory.new("searcho_side_info", bufnr),
    _window_id = window_id,
  }
  return setmetatable(tbl, SideInfo)
end

function SideInfo.show(self, msg)
  local highlighter = self._hl_factory:reset()
  if msg == "[0/0]" then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(self._window_id)
  highlighter:add_virtual({{" " .. msg, "Comment"}}, cursor[1] - 1, 0, {})
end

function SideInfo.clear(self)
  self._hl_factory:reset()
end

return M
