local repository = require("searcho.lib.repository").Repository.new("view")
local Inputter = require("searcho.view.inputter").Inputter
local Info = require("searcho.view.info").Info
local Searcher = require("searcho.core.searcher").Searcher

local M = {}

local View = {}
View.__index = View
M.View = View

function View.new(searcher_factory, input, right_input)
  vim.validate({
    searcher_factory = {searcher_factory, "function"},
    input = {input, "string", true},
    right_input = {right_input, "string", true},
  })

  local window_id = vim.api.nvim_get_current_win()
  local searcher = searcher_factory(window_id)
  local inputter = Inputter.new()
  local info = Info.new(inputter.bufnr, window_id)

  inputter:open(function(line)
    searcher:search(line)
    info:show()
  end, input, right_input)

  local tbl = {_inputter = inputter, _searcher = searcher, _info = info}
  local self = setmetatable(tbl, View)

  repository:set(inputter.window_id, self)
end

function View.open_searcher(method_name, input)
  View.new(Searcher[method_name], input)
end

function View.open_word_searcher(method_name, left, right)
  left = left or ""
  local input = left .. vim.fn.expand("<cword>")
  View.new(Searcher[method_name], input, right)
end

function View.recall_history(self, offset)
  self._inputter:recall_history(offset)
end

function View.close(self)
  self._closed = true
  self._inputter:close()
  repository:delete(self._inputter.window_id)
end

function View.finish(self)
  self._searcher:adjust()
  self._inputter:save_history()
  self:close()
  return self._searcher:finish()
end

function View.cancel(self)
  -- HACK: guard for firing autocmd many times
  if self._closed then
    return
  end

  self._inputter:save_history()
  self:close()
  self._searcher:cancel()
end

function View.move_cursor(self, method_name)
  self._searcher[method_name](self._searcher)
  self._info:show()
end

function View.get(id)
  return repository:get(id)
end

function View.current()
  local id = vim.api.nvim_get_current_win()
  return View.get(id)
end

function View.search_info()
  return Info.msg()
end

return M
