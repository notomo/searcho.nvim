local M = {}

local Highlighter = {}
Highlighter.__index = Highlighter

function Highlighter.add(self, hl_group, row, start_col, opts)
  opts.hl_group = hl_group
  vim.api.nvim_buf_set_extmark(self._bufnr, self._ns, row, start_col, opts)
end

function Highlighter.add_virtual(self, chunks, row, start_col, opts)
  opts.virt_text = chunks
  vim.api.nvim_buf_set_extmark(self._bufnr, self._ns, row, start_col, opts)
end

function Highlighter.add_ranged_virtual(self, strs, hl_group, start_row, start_col, end_row, end_col, opts)
  local args = {}

  local count = #strs
  if count == 1 then
    local o = vim.tbl_extend("force", {end_line = end_row, end_col = end_col}, opts)
    local arg = {{{strs[1], hl_group}}, start_row, start_col, o}
    table.insert(args, arg)
  elseif count > 1 then
    local row = start_row
    for _, str in ipairs(strs) do
      local o = vim.tbl_extend("force", {end_line = row + 1}, opts)
      local arg = {{{str, hl_group}}, row, 0, o}
      table.insert(args, arg)
      row = row + 1
    end
    args[1][3] = start_col
    args[#args][4].end_col = end_col
    args[#args][4].end_line = nil
  end

  for _, arg in ipairs(args) do
    self:add_virtual(unpack(arg))
  end
end

local HighlighterFactory = {}
HighlighterFactory.__index = HighlighterFactory
M.HighlighterFactory = HighlighterFactory

function HighlighterFactory.new(key, bufnr)
  vim.validate({key = {key, "string"}, bufnr = {bufnr, "number", true}})
  local ns = vim.api.nvim_create_namespace(key)
  local tbl = {_ns = ns, _bufnr = bufnr}
  return setmetatable(tbl, HighlighterFactory)
end

function HighlighterFactory.create(self, bufnr)
  bufnr = bufnr or self._bufnr
  local highlighter = {_bufnr = bufnr, _ns = self._ns}
  return setmetatable(highlighter, Highlighter)
end

function HighlighterFactory.reset(self, bufnr)
  bufnr = bufnr or self._bufnr
  local highlighter = self:create(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, self._ns, 0, -1)
  return highlighter
end

return M