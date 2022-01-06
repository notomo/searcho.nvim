local windowlib = require("searcho.lib.window")
local cursorlib = require("searcho.lib.cursor")
local wraplib = require("searcho.lib.wrap")
local vim = vim

local M = {}

local Inputter = {}
Inputter.__index = Inputter
M.Inputter = Inputter

Inputter.key_mapping_script = [[
inoremap <buffer> <CR> <Cmd>lua require("searcho").finish()<CR>
inoremap <buffer> <ESC> <Cmd>lua require("searcho").cancel()<CR>
inoremap <buffer> <C-n> <Cmd>lua require("searcho").forward_history()<CR>
inoremap <buffer> <C-p> <Cmd>lua require("searcho").backward_history()<CR>
]]

function Inputter.new(origin_bufnr)
  local bufnr = vim.api.nvim_create_buf(false, true)

  local origin_name = vim.api.nvim_buf_get_name(origin_bufnr)
  if origin_name == "" then
    origin_name = "[Scratch]"
  end
  local name = "searcho://" .. origin_name
  local old = vim.fn.bufnr(("^%s$"):format(name))
  if old ~= -1 then
    vim.api.nvim_buf_delete(old, { force = true })
  end
  vim.api.nvim_buf_call(bufnr, function()
    vim.api.nvim_exec(Inputter.key_mapping_script, false)
  end)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "searcho"

  local tbl = { window_id = nil, bufnr = bufnr, _history_offset = 0 }
  return setmetatable(tbl, Inputter)
end

function Inputter.open(self, callback, default_input, default_right_input)
  vim.validate({
    callback = { callback, "function" },
    default_input = { default_input, "string", true },
    default_right_input = { default_right_input, "string", true },
  })
  default_input = default_input or ""
  default_right_input = default_right_input or ""

  local window_id = vim.api.nvim_open_win(self.bufnr, true, {
    width = vim.o.columns,
    height = 1,
    relative = "editor",
    row = vim.o.lines - vim.o.cmdheight - 1, -- HACK: over statusline
    col = 0,
    external = false,
    style = "minimal",
  })
  vim.api.nvim_echo({}, false, {}) -- NOTE: for clear command-line
  vim.wo[window_id].winhighlight = "Normal:Normal,SignColumn:Normal,Search:None"
  vim.wo[window_id].signcolumn = "yes:1"
  self.window_id = window_id

  vim.cmd(
    (
      "autocmd WinClosed,WinLeave,TabLeave,BufLeave,BufWipeout,InsertLeave <buffer=%s> ++once lua require('searcho.command').Command.new('close', %s)"
    ):format(self.bufnr, window_id)
  )

  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = wraplib.traceback(function()
      local input_line = self:_get_line()
      callback(input_line)

      if vim.api.nvim_buf_line_count(self.bufnr) == 1 then
        return
      end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(self.bufnr, 1, -1, false, {})
      end)
    end),
  })
  self:_set_line(default_input .. default_right_input)
  vim.cmd("startinsert!")
  cursorlib.to_left_by(window_id, default_right_input)
end

function Inputter._set_line(self, line)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, { vim.split(line, "\n", true)[1] })
end

function Inputter._get_line(self)
  return vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true)[1]
end

function Inputter.recall_history(self, offset)
  if self._history_offset == 0 then
    self:save_history()
  end

  local next_index = self._history_offset + offset
  next_index = math.min(next_index, 0)
  next_index = math.max(next_index, -vim.fn.histnr("search"))

  local history = vim.fn.histget("search", next_index)
  self:_set_line(history)
  cursorlib.set_column(#history + 1)

  self._history_offset = next_index
end

function Inputter.save_history(self)
  local input_line = self:_get_line()
  vim.fn.histadd("search", input_line)
end

function Inputter.close(self)
  -- NOTICE: because sometimes the buffer is not deleted.
  vim.api.nvim_buf_delete(self.bufnr, { force = true })
  windowlib.close(self.window_id)
  vim.cmd("stopinsert")
end

return M
