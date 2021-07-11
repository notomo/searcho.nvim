local M = {}

local function _adjust(line, column)
  local pattern = ("\\v\\k*%%%sc\\zs."):format(column)
  return vim.fn.matchstr(line, pattern)
end

function M.get_text(bufnr, start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local count = #lines
  if count == 0 then
    return ""
  end
  if count == 1 then
    local end_line = lines[1]:sub(start_col, end_col)
    local last_char = _adjust(lines[#lines], end_col)
    local s = end_line:gsub(".$", last_char)
    return s
  end
  lines[1] = lines[1]:sub(start_col)
  local end_line = lines[#lines]:sub(1, end_col)
  local last_char = _adjust(lines[#lines], end_col)
  local s = end_line:gsub(".$", last_char)
  lines[#lines] = s
  return table.concat(lines, "\n")
end

return M
