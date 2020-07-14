local M = {}

local mode = "c"
local large_scrolloff = 999

local centering_cursor = function()
  local prev_scrolloff = vim.wo.scrolloff
  if prev_scrolloff == large_scrolloff then
    return
  elseif prev_scrolloff > large_scrolloff then
    -- HACK: `vim.wo.scrolloff` should raise error if not set
    prev_scrolloff = vim.o.scrolloff
  end

  vim.wo.scrolloff = large_scrolloff

  local bufnr = vim.fn.bufnr("%")
  local on_finished =
    ("autocmd CmdlineLeave <buffer=%s> ++once lua require('searcho/search').restore_option(%s)"):format(
    bufnr,
    prev_scrolloff
  )
  vim.api.nvim_command(on_finished)
end

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
  local before = get_keymap(bufnr, keymap.lhs)

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
        nowait = before.nowait == 1,
        silent = before.silent == 1,
        expr = before.expr == 1,
        noremap = before.noremap == 1,
        script = before.script == 1,
        unique = before.unique == 1
      }
    }
  end

  return info
end

M.restore_option = function(scrolloff)
  vim.wo.scrolloff = scrolloff
end

M.restore = function(keymaps, bufnr)
  for _, keymap in pairs(keymaps) do
    if keymap.before ~= nil then
      vim.api.nvim_buf_set_keymap(keymap.bufnr, mode, keymap.lhs, keymap.before.rhs, keymap.before.opts)
    else
      vim.api.nvim_buf_del_keymap(keymap.bufnr, mode, keymap.lhs)
    end
  end
  M.setup_on_moved(bufnr)
end

local group_name = "SearchoGroup"

M.setup_on_moved = function(bufnr)
  local group = group_name .. bufnr
  vim.api.nvim_command(("augroup %s"):format(group))
  vim.api.nvim_command("autocmd!")
  local on_moved =
    ("autocmd CursorMoved <buffer=%s> ++once autocmd %s CursorMoved <buffer=%s> ++once lua require('searcho/search').on_cursor_moved_after_end(%s)"):format(
    bufnr,
    group,
    bufnr,
    bufnr
  )
  vim.api.nvim_command(on_moved)
  vim.api.nvim_command("augroup END")
end

M.on_cursor_moved_after_end = function(_)
  -- :h autocmd-searchpat
  vim.schedule(
    function()
      vim.api.nvim_command("nohlsearch")
    end
  )
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

  centering_cursor()

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

  centering_cursor()

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

  -- make unique by lhs
  local keymaps = {}
  for _, keymap in ipairs(M.keymaps) do
    keymaps[keymap.lhs] = keymap
  end

  local prev_keymaps = {}
  for _, keymap in pairs(keymaps) do
    local prev = set_keymap(keymap, bufnr)
    prev_keymaps[prev.lhs] = prev
  end

  local on_finished =
    ("autocmd CmdlineLeave <buffer=%s> ++once lua require('searcho/search').restore(%s, %s)"):format(
    bufnr,
    vim.inspect(prev_keymaps),
    bufnr
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

M.stay_forward = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  M.setup()

  local word, start_col, _ = unpack(vim.fn.matchstrpos(line, "\\v\\k*%" .. col .. "c\\k+"))
  if word == "" then
    return "/"
  end

  local left = vim.api.nvim_eval('"\\<Left>"')
  return left:rep(col - start_col) .. "/"
end

M.stay_backward = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  M.setup()

  local word, _, end_col = unpack(vim.fn.matchstrpos(line, "\\v\\k*%" .. col .. "c\\k+"))
  if word == "" then
    return "?"
  end

  local right = vim.api.nvim_eval('"\\<Right>"')
  return right:rep(end_col - col) .. "?"
end

M.next = function()
  local bufnr = vim.fn.bufnr("%")
  M.setup_on_moved(bufnr)
  return "n"
end

M.prev = function()
  local bufnr = vim.fn.bufnr("%")
  M.setup_on_moved(bufnr)
  return "N"
end

return M
