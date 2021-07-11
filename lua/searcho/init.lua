local Command = require("searcho.command").Command

local searcho = {}

function searcho.forward(input)
  Command.new("search", "forward", input)
end

function searcho.backward(input)
  Command.new("search", "backward", input)
end

function searcho.forward_word(opts)
  Command.new("search_word", "forward_word", opts)
end

function searcho.backward_word(opts)
  Command.new("search_word", "backward_word", opts)
end

function searcho.finish()
  Command.new("finish")
end

function searcho.cancel()
  Command.new("cancel")
end

function searcho.next()
  Command.new("move_cursor_in_normal", "next")
end

function searcho.previous()
  Command.new("move_cursor_in_normal", "previous")
end

function searcho.next_match()
  Command.new("move_cursor", "next_match")
end

function searcho.previous_match()
  Command.new("move_cursor", "previous_match")
end

function searcho.next_page()
  Command.new("move_cursor", "next_page")
end

function searcho.previous_page()
  Command.new("move_cursor", "previous_page")
end

function searcho.forward_history()
  Command.new("recall_history", 1)
end

function searcho.backward_history()
  Command.new("recall_history", -1)
end

return searcho
