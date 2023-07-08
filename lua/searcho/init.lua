local searcho = {}

--- Setup keymap for command-line mode that type is search.
--- @param keymap_func fun(vim:table) set keymap function. (The argument is patched vim object)
function searcho.setup_keymaps(keymap_func)
  require("searcho.command").setup_keymaps(keymap_func)
end

--- @class SearchoOption
--- @field char_pattern string?  (default = "\k")

--- Returns a command to start searching forward.
--- @param opts SearchoOption?: |SearchoOption|
--- @return string # command to use expr mapping
function searcho.forward(opts)
  return require("searcho.command").forward(opts)
end

--- Returns a command to start searching backward.
--- @param opts SearchoOption?: |SearchoOption|
--- @return string # command to use expr mapping
function searcho.backward(opts)
  return require("searcho.command").backward(opts)
end

--- Returns a command with the following side-effect.
--- - Disable search highlight on next cursor moved.
--- @return string # command to use expr mapping
function searcho.normal(cmd)
  return require("searcho.command").normal(cmd)
end

return searcho
