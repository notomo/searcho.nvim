local searcho = {}

function searcho.setup_keymaps(keymap_func)
  return require("searcho.command").setup_keymaps(keymap_func)
end

function searcho.word_forward(opts)
  require("searcho.command").word_forward(opts)
end

function searcho.word_backward(opts)
  require("searcho.command").word_backward(opts)
end

function searcho.normal(cmd)
  return require("searcho.command").normal(cmd)
end

return searcho
