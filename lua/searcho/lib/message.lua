local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  vim.validate({err = {err, "string"}})
  error(prefix .. err)
end

function M.warn(msg)
  vim.validate({msg = {msg, "string"}})
  vim.api.nvim_echo({{prefix .. msg, "WarningMsg"}}, true, {})
end

function M.info(msg)
  vim.validate({msg = {msg, "string"}})
  vim.api.nvim_echo({{prefix .. msg}}, true, {})
end

function M.raw_info(msg)
  vim.validate({msg = {msg, "string"}})
  vim.api.nvim_echo({{msg}}, true, {})
end

function M.validate(tbl)
  local errs = {}
  for key, value in pairs(tbl) do
    local ok, result = pcall(vim.validate, {[key] = value})
    if not ok then
      local msg_head = vim.split(result, "\n")[1]
      table.insert(errs, ("%s: %s"):format(msg_head, vim.inspect(value[1])))
    end
  end
  if #errs ~= 0 then
    return table.concat(errs, "\n")
  end
end

return M
