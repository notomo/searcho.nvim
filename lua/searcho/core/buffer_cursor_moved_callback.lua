local _callbacks = {}

local vim = vim

local BufferCursorMovedCallback = {}
BufferCursorMovedCallback.__index = BufferCursorMovedCallback

function BufferCursorMovedCallback.new(bufnr, callback)
  vim.validate({
    bufnr = { bufnr, "number" },
    callback = { callback, "function", true },
  })
  local group_name = "searcho_buffer_cursor_moved_callback"
  vim.api.nvim_create_augroup(group_name, {})
  local tbl = {
    _group_name = group_name,
    _bufnr = bufnr,
    _callback = callback or function() end,
  }
  local self = setmetatable(tbl, BufferCursorMovedCallback)
  _callbacks[bufnr] = self
  return self
end

function BufferCursorMovedCallback.setup(self)
  self:disable()
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = self._group_name,
    buffer = self._bufnr,
    once = true,
    callback = function()
      BufferCursorMovedCallback.get(self._bufnr):_setup()
    end,
  })
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    group = self._group_name,
    buffer = self._bufnr,
    once = true,
    callback = function()
      self:disable()
      self._callback()
    end,
  })
end

function BufferCursorMovedCallback._setup(self)
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = self._group_name,
    buffer = self._bufnr,
    once = true,
    callback = function()
      self._callback()
      _callbacks[self._bufnr] = nil
    end,
  })
end

function BufferCursorMovedCallback.disable(self)
  vim.api.nvim_clear_autocmds({ group = self._group_name })
end

function BufferCursorMovedCallback.reset(self)
  self:disable()
  self:_setup()
end

function BufferCursorMovedCallback.get(bufnr)
  local self = _callbacks[bufnr]
  if not self then
    return BufferCursorMovedCallback.new(bufnr)
  end
  return self
end

return BufferCursorMovedCallback
