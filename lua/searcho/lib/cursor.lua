local M = {}

function M.set_column(column)
  vim.validate({column = {column, "number"}})
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, {row, column - 1})
end

local function trim_intersection(str, mask_str)
  local chars = vim.fn.reverse(vim.fn.split(mask_str, "\\zs"))
  local suffix = mask_str
  for _, c in ipairs(chars) do
    if vim.endswith(str, suffix) then
      local s = str:gsub(suffix .. "$", "")
      return s
    end
    suffix = suffix:gsub(c .. "$", "")
  end
  return str
end

function M.word_head_position(window_id)
  local row, column = unpack(vim.api.nvim_win_get_cursor(window_id))

  local word, line
  vim.api.nvim_win_call(window_id, function()
    word = vim.fn.expand("<cword>")
    line = vim.fn.getline(".")
  end)

  local pattern = ("\\v\\k*%%%sc\\zs\\k+"):format(column + 1)
  local suffix = vim.fn.matchstr(line, pattern)
  local width = vim.fn.strdisplaywidth(trim_intersection(word, suffix))
  local new_column = column - width
  if new_column < 0 then
    return {row, 0}
  end

  return {row, new_column}
end

function M.to_left_by(window_id, str)
  local row, column = unpack(vim.api.nvim_win_get_cursor(window_id))
  local length = vim.fn.strlen(str)
  vim.api.nvim_win_set_cursor(window_id, {row, column - length})
end

function M.left(window_id, row, column)
  if column > 0 then
    return vim.api.nvim_win_set_cursor(window_id, {row, column - 1})
  end
  if row > 1 then
    vim.api.nvim_win_set_cursor(window_id, {row - 1, 0})
    local last_column = vim.api.nvim_win_call(window_id, function()
      return vim.fn.col("$")
    end)
    return vim.api.nvim_win_set_cursor(window_id, {row - 1, last_column})
  end

  local last_row = vim.api.nvim_win_call(window_id, function()
    return vim.fn.line("$")
  end)
  vim.api.nvim_win_set_cursor(window_id, {last_row, 0})
  local last_column = vim.api.nvim_win_call(window_id, function()
    return vim.fn.col("$")
  end)
  return vim.api.nvim_win_set_cursor(window_id, {last_row, last_column})
end

function M.next_page_row(window_id)
  local count
  local last_row = vim.api.nvim_win_call(window_id, function()
    count = vim.fn.line("$")
    return vim.fn.line("w$")
  end)
  if count == last_row then
    return last_row
  end
  return last_row + 1
end

function M.previous_page_row(window_id)
  local first_row = vim.api.nvim_win_call(window_id, function()
    return vim.fn.line("w0")
  end)
  if first_row == 1 then
    return first_row
  end
  return first_row - 1
end

return M