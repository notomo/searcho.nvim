local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  vim.validate({ err = { err, "string" } })
  error(prefix .. err)
end

function M.warn(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { prefix .. msg, "WarningMsg" } }, true, {})
end

function M.info(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { prefix .. msg } }, true, {})
end

function M.raw_info(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { msg } }, true, {})
end

function M.vim_warn(msg)
  vim.validate({ msg = { msg, "string" } })
  local s, e = msg:find("Vim%(%S+%):")
  if s then
    msg = msg:sub(e + 1)
  elseif vim.startswith(msg, "Vim:") then
    msg = msg:sub(#"Vim:" + 1)
  end
  M.warn(msg)
end

return M
