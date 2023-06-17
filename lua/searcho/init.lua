local searcho = {}

function searcho.setup_keymaps(keymap_func)
  return require("searcho.command").setup_keymaps(keymap_func)
end

function searcho.word_forward()
  require("searcho.command").word("forward")
end

function searcho.word_backward()
  require("searcho.command").word("backward")
end

function searcho.normal(cmd)
  return require("searcho.command").normal(cmd)
end

return searcho
