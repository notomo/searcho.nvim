local Decorator = require("searcho.vendor.misclib.decorator")

function Decorator.add_virtual_text_range(self, strs, hl_group, start_row, start_col, opts)
  local args = {}

  local count = #strs
  if count == 1 then
    local str = strs[1]
    table.insert(args, { start_row, start_col, { { str, hl_group } }, opts })
  elseif count > 1 then
    local eol = vim.opt.listchars:get().eol or ""
    local row = start_row
    for _, str in ipairs(strs) do
      table.insert(args, { row, 0, { { str .. eol, hl_group } }, opts })
      row = row + 1
    end
    args[1][2] = start_col
    args[#args][3][1][1] = strs[#strs]
  end
  args = vim.tbl_filter(function(arg)
    return arg[3][1][1] ~= ""
  end, args)

  for _, arg in ipairs(args) do
    self:add_virtual_text(unpack(arg))
  end
end

return Decorator
