local callbacks = {}

local vim = vim

local group_name = "searcho_buffer_cursor_moved_callback"
vim.cmd(([[
augroup %s
augroup END
]]):format(group_name))

local M = {}

local BufferCursorMovedCallback = {}
BufferCursorMovedCallback.__index = BufferCursorMovedCallback
M.BufferCursorMovedCallback = BufferCursorMovedCallback

function BufferCursorMovedCallback.new(bufnr, callback)
  vim.validate({ bufnr = { bufnr, "number" }, callback = { callback, "function", true } })
  local tbl = {
    _group_name = group_name,
    _bufnr = bufnr,
    _callback = callback or function() end,
  }
  local self = setmetatable(tbl, BufferCursorMovedCallback)
  callbacks[bufnr] = self
  return self
end

function BufferCursorMovedCallback.setup(self)
  self:disable()
  vim.cmd(
    (
      [[autocmd %s CursorMoved <buffer=%s> ++once lua require("searcho.core.buffer_cursor_moved_callback").BufferCursorMovedCallback.get(%s):_setup()]]
    ):format(self._group_name, self._bufnr, self._bufnr)
  )
  vim.cmd(
    (
      [[autocmd %s BufLeave <buffer=%s> ++once lua require("searcho.core.buffer_cursor_moved_callback").BufferCursorMovedCallback.get(%s):_clear()]]
    ):format(self._group_name, self._bufnr, self._bufnr)
  )
end

function BufferCursorMovedCallback._setup(self)
  vim.cmd(
    (
      [[autocmd %s CursorMoved <buffer=%s> ++once lua require("searcho.core.buffer_cursor_moved_callback").BufferCursorMovedCallback.get(%s):_execute()]]
    ):format(self._group_name, self._bufnr, self._bufnr)
  )
end

function BufferCursorMovedCallback._execute(self)
  self._callback()
  callbacks[self._bufnr] = nil
end

function BufferCursorMovedCallback.disable(self)
  vim.cmd(([[autocmd! %s CursorMoved <buffer=%s>]]):format(self._group_name, self._bufnr))
  vim.cmd(([[autocmd! %s BufLeave <buffer=%s>]]):format(self._group_name, self._bufnr))
end

function BufferCursorMovedCallback._clear(self)
  self:disable()
  self._callback()
end

function BufferCursorMovedCallback.reset(self)
  self:disable()
  self:_setup()
end

function BufferCursorMovedCallback.get(bufnr)
  local self = callbacks[bufnr]
  if not self then
    return BufferCursorMovedCallback.new(bufnr)
  end
  return self
end

return M
