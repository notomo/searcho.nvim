local M = {}

local mode = "c"

local get_keymap = function(bufnr, lhs)
  local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == lhs then
      return keymap
    end
  end
  return nil
end

local set_keymap = function(keymap, bufnr)
  local before = get_keymap(keymap.lhs)

  vim.api.nvim_buf_set_keymap(
    bufnr,
    mode,
    keymap.lhs,
    keymap.rhs,
    {
      noremap = keymap.noremap,
      expr = keymap.expr
    }
  )

  local info = {lhs = keymap.lhs}
  if before ~= nil then
    info.before = {
      rhs = before.rhs,
      opts = {
        nowait = before.nowait,
        silent = before.silent,
        expr = before.expr,
        noremap = before.noremap,
        script = before.script,
        unique = before.unique
      }
    }
  end

  return info
end

M.restore = function(keymaps)
  for _, keymap in ipairs(keymaps) do
    if keymap.before ~= nil then
      vim.api.nvim_buf_set_keymap(mode, keymap.lhs, keymap.before.rhs, keymap.before.opts)
    else
      vim.api.nvim_buf_del_keymap(keymap.bufnr, mode, keymap.lhs)
    end
  end
end

M.next_page = function()
  local pattern = vim.fn.getcmdline()
  if pattern == "" then
    return ""
  end

  local first_row = vim.fn.line("w0")
  local last_row = vim.fn.line("w$")
  local current_row = vim.fn.line(".")
  local current_col = vim.fn.col(".")
  local before_row = current_row
  local before_col = current_col
  local count = 0
  repeat
    local row, col = unpack(vim.fn.searchpos(pattern))
    if (current_row == row and current_col == col) or (before_row == row and before_col == col) then
      return ""
    end
    before_row = row
    before_col = col
    count = count + 1
  until row < first_row or last_row < row

  local ctrl_g = vim.api.nvim_eval('"\\<C-g>"')
  return (ctrl_g):rep(count)
end

M.prev_page = function()
  local pattern = vim.fn.getcmdline()
  if pattern == "" then
    return ""
  end

  local first_row = vim.fn.line("w0")
  local last_row = vim.fn.line("w$")
  local current_row = vim.fn.line(".")
  local current_col = vim.fn.col(".")
  local before_row = current_row
  local before_col = current_col
  local count = 0
  repeat
    local row, col = unpack(vim.fn.searchpos(pattern, "b"))
    if (current_row == row and current_col == col) or (before_row == row and before_col == col) then
      return ""
    end
    before_row = row
    before_col = col
    count = count + 1
  until row < first_row or last_row < row

  local ctrl_t = vim.api.nvim_eval('"\\<C-t>"')
  return (ctrl_t):rep(count)
end

M.keymaps = {
  {
    lhs = "<C-n>",
    rhs = "searcho#do('next_page')",
    expr = true,
    noremap = true
  },
  {
    lhs = "<C-p>",
    rhs = "searcho#do('prev_page')",
    expr = true,
    noremap = true
  }
}

M.setup = function()
  local bufnr = vim.fn.bufnr("%")

  local keymaps = {}
  for _, keymap in ipairs(M.keymaps) do
    table.insert(keymaps, set_keymap(keymap))
  end

  local on_finished =
    ("autocmd CmdlineLeave <buffer=%s> ++once lua require('searcho/search').restore(%s)"):format(
    bufnr,
    vim.inspect(keymaps)
  )
  vim.api.nvim_command(on_finished)
end

M.forward = function()
  M.setup()
  return "/"
end

M.backward = function()
  M.setup()
  return "?"
end

return M
