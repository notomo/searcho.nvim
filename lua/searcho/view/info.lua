local HighlighterFactory = require("searcho.lib.highlight").HighlighterFactory
local vim = vim

local M = {}

local Info = {}
Info.__index = Info
M.Info = Info

function Info.new(bufnr, window_id)
  vim.validate({bufnr = {bufnr, "number"}, window_id = {window_id, "number"}})
  local tbl = {_window_id = window_id, _hl_factory = HighlighterFactory.new("searcho", bufnr)}
  return setmetatable(tbl, Info)
end

function Info.show(self)
  local highlighter = self._hl_factory:reset()
  local msg = vim.api.nvim_win_call(self._window_id, function()
    return self:_count()
  end)
  highlighter:add_virtual({{msg, "Comment"}}, 0, 0, {})
end

function Info._count()
  local count = vim.fn.searchcount()
  if vim.tbl_isempty(count) then
    return ""
  end

  if count.incomplete == 1 then
    return "[?/??]"
  elseif count.incomplete == 0 then
    return ("[%d/%d]"):format(count.current, count.total)
  end
  -- count.incomplete == 2
  if count.total > count.maxcount and count.current > count.maxcount then
    return ("[>%d/>%d]"):format(count.current, count.total)
  elseif count.total > count.maxcount then
    return ("[%d/>%d]"):format(count.current, count.total)
  end

  return ""
end

function Info.msg()
  local prefix
  if vim.v.searchforward == 1 then
    prefix = "/"
  else
    prefix = "?"
  end
  return ("%s%s %s"):format(prefix, vim.fn.getreg("/"), Info._count())
end

return M
