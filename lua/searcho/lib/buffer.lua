local M = {}

local function _adjust(line, start_col, end_col)
  local end_line = line:sub(start_col, end_col)
  local pattern = ("\\v\\k*%%%sc\\zs."):format(end_col)
  local last_char = vim.fn.matchstr(line, pattern)
  if last_char == "" then
    return end_line .. "\n"
  end
  local str = end_line:gsub(".$", last_char)
  return str
end

function M.get_text(bufnr, start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local count = #lines
  if count == 0 then
    return ""
  end
  if count == 1 then
    return _adjust(lines[count], start_col, end_col)
  end
  lines[1] = lines[1]:sub(start_col)
  lines[count] = _adjust(lines[count], 1, end_col)
  return table.concat(lines, "\n")
end

return M
