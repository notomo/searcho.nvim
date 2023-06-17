local M = {}

function M.with_restore(fn)
  local view = vim.fn.winsaveview()

  fn()

  vim.fn.winrestview({
    topline = view.topline,
    leftcol = view.leftcol,
  })
end

return M
