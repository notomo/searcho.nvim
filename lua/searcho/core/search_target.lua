-- depends whichwrap including h,l

local M = {}

local get_offsets = function(line, cursor, char_pattern)
  local pattern = ([=[\v%s*%%%sc%s+]=]):format(char_pattern, cursor[2] + 1, char_pattern)
  local matched_str, start_byte = unpack(vim.fn.matchstrpos(line, pattern))
  if start_byte == -1 then
    return 0, 0
  end

  local after_part = vim.fn.strpart(line, start_byte)
  local s = #line - #after_part
  local e = s + #matched_str
  return cursor[2] - s + 1, e - cursor[2] - 1
end

function M.forward_command(cursor, char_pattern)
  local line = vim.api.nvim_get_current_line()
  local offset = get_offsets(line, cursor, char_pattern)

  local adjust_cmd
  if cursor[1] == 1 and cursor[2] <= offset then
    adjust_cmd = "G$"
  else
    adjust_cmd = ("h"):rep(offset)
  end

  return adjust_cmd .. "/"
end

function M.backward_command(cursor, char_pattern)
  local line = vim.api.nvim_get_current_line()
  local _, offset = get_offsets(line, cursor, char_pattern)

  local adjust_cmd
  local last_row = vim.api.nvim_buf_line_count(0)
  if cursor[1] == last_row and cursor[2] <= vim.fn.col("$") - 2 then
    adjust_cmd = "gg0"
  else
    adjust_cmd = ("l"):rep(offset)
  end

  return adjust_cmd .. "?"
end

return M
