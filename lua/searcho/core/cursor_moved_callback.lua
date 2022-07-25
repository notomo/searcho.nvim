local vim = vim

local CursorMovedCallback = {}
CursorMovedCallback.__index = CursorMovedCallback

local last = nil

function CursorMovedCallback.new()
  local group_name = "searcho_cursor_moved_callback"
  vim.api.nvim_create_augroup(group_name, {})
  local tbl = {
    _group_name = group_name,
    _callback = function()
      -- :h autocmd-searchpat
      vim.schedule(function()
        vim.cmd.nohlsearch()
      end)
    end,
  }
  local self = setmetatable(tbl, CursorMovedCallback)
  last = self
  return self
end

function CursorMovedCallback.setup(self)
  self:disable()
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = self._group_name,
    pattern = { "*" },
    once = true,
    callback = function()
      CursorMovedCallback.get():_setup()
    end,
  })
end

function CursorMovedCallback._setup(self)
  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = self._group_name,
    pattern = { "*" },
    once = true,
    callback = function()
      self._callback()
    end,
  })
end

function CursorMovedCallback.disable(self)
  vim.api.nvim_clear_autocmds({ group = self._group_name })
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

return CursorMovedCallback
