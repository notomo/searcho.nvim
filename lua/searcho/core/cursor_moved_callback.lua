local vim = vim

local group_name = "searcho_cursor_moved_callback"
vim.cmd(([[
augroup %s
augroup END
]]):format(group_name))

local M = {}

local CursorMovedCallback = {}
CursorMovedCallback.__index = CursorMovedCallback
M.CursorMovedCallback = CursorMovedCallback

local last = nil

function CursorMovedCallback.new()
  local tbl = {
    _group_name = group_name,
    _callback = function()
      -- :h autocmd-searchpat
      vim.schedule(function()
        vim.cmd("nohlsearch")
      end)
    end,
  }
  local self = setmetatable(tbl, CursorMovedCallback)
  last = self
  return self
end

function CursorMovedCallback.setup(self)
  self:disable()
  vim.cmd(([[autocmd %s CursorMoved * ++once lua require("searcho.core.cursor_moved_callback").CursorMovedCallback.get():_setup()]]):format(self._group_name))
end

function CursorMovedCallback._setup(self)
  vim.cmd(([[autocmd %s CursorMoved * ++once lua require("searcho.core.cursor_moved_callback").CursorMovedCallback.get():_execute()]]):format(self._group_name))
end

function CursorMovedCallback._execute(self)
  self._callback()
end

function CursorMovedCallback.disable(self)
  vim.cmd(([[autocmd! %s CursorMoved]]):format(self._group_name))
end

function CursorMovedCallback.reset(self)
  self:disable()
  self:_setup()
end

function CursorMovedCallback.get()
  local self = last
  if not self then
    return CursorMovedCallback.new()
  end
  return self
end

return M
