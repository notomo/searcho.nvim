local searcho = {}

function searcho.setup_keymaps(keymap_func)
  return require("searcho.command").setup_keymaps(keymap_func)
end

function searcho.forward(opts)
  return require("searcho.command").forward(opts)
end

function searcho.backward(opts)
  return require("searcho.command").backward(opts)
end

function searcho.normal(cmd)
  return require("searcho.command").normal(cmd)
end

return searcho
