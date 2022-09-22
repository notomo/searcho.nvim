local searcho = {}

function searcho.forward(input)
  require("searcho.command").search("forward", input)
end

function searcho.backward(input)
  require("searcho.command").search("backward", input)
end

function searcho.forward_word(opts)
  require("searcho.command").search_word("forward_word", opts)
end

function searcho.backward_word(opts)
  require("searcho.command").search_word("backward_word", opts)
end

function searcho.finish(opts)
  require("searcho.command").finish(opts)
end

function searcho.cancel()
  require("searcho.command").cancel()
end

function searcho.next(opts)
  require("searcho.command").move_cursor_in_normal("next", opts)
end

function searcho.previous(opts)
  require("searcho.command").move_cursor_in_normal("previous", opts)
end

function searcho.next_match()
  require("searcho.command").move_cursor("next_match")
end

function searcho.previous_match()
  require("searcho.command").move_cursor("previous_match")
end

function searcho.next_page()
  require("searcho.command").move_cursor("next_page")
end

function searcho.previous_page()
  require("searcho.command").move_cursor("previous_page")
end

function searcho.forward_history()
  require("searcho.command").recall_history(1)
end

function searcho.backward_history()
  require("searcho.command").recall_history(-1)
end

return searcho
