local M = {}

function M.disable()
  vim.schedule(function()
    vim.cmd.nohlsearch()
  end)
end

local group = vim.api.nvim_create_augroup("searcho.search_highlight", {})

function M.disable_on_next_moved()
  vim.api.nvim_clear_autocmds({ group = group })

  vim.schedule(function()
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      group = group,
      pattern = { "*" },
      once = true,
      callback = function()
        M.disable()
      end,
    })
  end)
end

return M
