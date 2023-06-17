local M = {}

function M.for_search(fn)
  return function(args)
    local typ = args.file
    if typ ~= "/" and typ ~= "?" then
      return
    end
    return fn(args)
  end
end

return M
