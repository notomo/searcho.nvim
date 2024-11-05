local M = {}

function M.with_cleanup()
  local original_vim = vim

  local cleanup_targets = {}
  local cleanup = function()
    for _, keymap in ipairs(cleanup_targets) do
      local ok, err = pcall(original_vim.keymap.del, keymap.modes, keymap.lhs, keymap.opts)
      if not ok and err and not err:match("E31: No such mapping") then
        error(err)
      end
    end
  end

  local set = function(modes, lhs, rhs, opts)
    table.insert(cleanup_targets, {
      modes = modes,
      lhs = lhs,
      opts = opts,
    })
    original_vim.keymap.set(modes, lhs, rhs, opts)
  end

  local keymap = setmetatable({ set = set }, {
    __index = function(_, k)
      return original_vim.keymap[k]
    end,
  })
  local vim = setmetatable({ keymap = keymap }, {
    __index = function(_, k)
      return original_vim[k]
    end,
  })
  return vim, cleanup
end

return M
