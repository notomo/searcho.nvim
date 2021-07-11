local vim = vim

local M = {}

local group_name = "searcho_on_moved"
vim.cmd(([[
augroup %s
augroup END
]]):format(group_name))

function M.setup()
  vim.cmd(([[
autocmd! %s CursorMoved <buffer>
autocmd %s CursorMoved <buffer> ++once lua require("searcho.core.on_moved")._setup()
]]):format(group_name, group_name))
end

function M.disable()
  vim.cmd(([[autocmd! %s CursorMoved <buffer>]]):format(group_name))
end

function M.reset()
  M.disable()
  M._setup()
end

function M._setup()
  vim.cmd(([[autocmd %s CursorMoved <buffer> ++once lua require("searcho.core.on_moved")._disable_highlight()]]):format(group_name))
end

function M._disable_highlight()
  -- :h autocmd-searchpat
  vim.schedule(function()
    vim.cmd("nohlsearch")
  end)
end

return M
