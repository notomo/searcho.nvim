local helper = require("searcho.test.helper")
local searcho = helper.require("searcho")

describe("searcho.forward()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("searches in forward", function()
    helper.set_lines([[

target
]])

    searcho.forward("target")
    searcho.finish()

    assert.current_line("target")
  end)

  it("saves v:searchforward as forward", function()
    helper.set_lines([[
target1

target2

target3]])
    vim.cmd.normal({ args = { "j" }, bang = true })

    searcho.forward("target")
    searcho.finish()
    vim.cmd.normal({ args = { "0" }, bang = true }) -- HACK
    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("target3")
  end)

  it("ignores regexp error on inputting", function()
    searcho.forward("\\z")
  end)

  it("does not raise error if input has slashes", function()
    searcho.forward("\\v///")
  end)

  it("ignores `search hit BOTTOM` error when search result is empty", function()
    searcho.forward("target")

    assert.no.exists_message("search hit BOTTOM, continuing at TOP")
  end)

  it("can set key mapping by FileType autocmd", function()
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = { "searcho" },
      once = true,
      callback = function()
        vim.keymap.set("n", "TEST", function()
          vim.api.nvim_echo({ { "key_mapping_test" }, { "\n" } }, true, {})
        end)
      end,
    })

    searcho.forward("")
    vim.api.nvim_feedkeys("TEST", "x", true)

    assert.exists_message("key_mapping_test")
  end)
end)

describe("searcho.backward()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("searches in backward", function()
    helper.set_lines([[
target

]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    searcho.backward("target")
    searcho.finish()

    assert.current_line("target")
  end)

  it("saves v:searchforward as backward", function()
    helper.set_lines([[
target1

target2

target3]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    searcho.backward("target")
    searcho.finish()
    vim.cmd.normal({ args = { "0" }, bang = true }) -- HACK
    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("target1")
  end)
end)

describe("searcho.forward_word()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("stays in the cursor word", function()
    helper.set_lines([[
target 1

target 2

target 3
]])

    searcho.forward_word()
    searcho.finish()

    assert.current_line("target 1")
  end)

  it("searches a forward word", function()
    helper.set_lines([[
target 1

target 2

target 3
]])

    searcho.forward_word()
    searcho.finish()
    searcho.next()

    assert.current_line("target 2")
  end)
end)

describe("searcho.backward_word()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("stays in the cursor word", function()
    helper.set_lines([[
 target 1

 target 2

 target 3
]])
    vim.cmd.normal({ args = { "l" }, bang = true })

    searcho.backward_word()
    searcho.finish()

    assert.current_line(" target 1")
  end)

  it("searches a backward word", function()
    helper.set_lines([[
target 1

target 2

target 3
]])
    vim.cmd.normal({ args = { "2j" }, bang = true })

    searcho.backward_word()
    searcho.finish()
    vim.cmd.normal({ args = { "0" }, bang = true }) -- HACK
    searcho.next()

    assert.current_line("target 1")
  end)
end)

describe("searcho.cancel()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("cancels searching", function()
    helper.set_lines([[
start

target
]])
    searcho.forward("target")

    searcho.cancel()

    assert.current_line("start")
  end)

  it("restores scrolloff", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5
    helper.set_lines([[





target
]])

    searcho.forward("target")
    searcho.cancel()

    assert.equals(0, vim.o.scrolloff)
  end)
end)

describe("searcho.finish()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows info", function()
    helper.set_lines([[

target
target
]])
    searcho.forward("target")

    searcho.finish({ add_to_history = true })

    assert.exists_message("/target %[1/2%]")
  end)

  it("shows regexp error", function()
    searcho.forward("\\z")
    searcho.finish()

    assert.exists_message("%(NFA%) Unknown operator")
  end)

  it("shows pattern not found error", function()
    searcho.forward("not found")
    searcho.finish()

    assert.exists_message("E486: Pattern not found")
  end)

  it("restores scrolloff", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5
    helper.set_lines([[





target
]])

    searcho.forward("target")
    searcho.finish()

    assert.equals(0, vim.o.scrolloff)
  end)

  it("adds old position to jumplist", function()
    helper.set_lines([[
target1

target2
]])
    vim.cmd.normal({ args = { "$" }, bang = true })

    searcho.forward("target")
    searcho.finish()
    vim.cmd.normal({ args = { vim.api.nvim_eval('"\\<C-o>"') }, bang = true })

    assert.current_line("target1")
  end)

  it("can go back to visual mode", function()
    helper.set_lines([[
hoge
foo
]])

    vim.cmd.normal({ args = { "V" }, bang = true })
    searcho.forward("foo")
    searcho.finish()

    assert.mode("V")
    assert.current_line("foo")

    vim.cmd.normal({ args = { "o" }, bang = true })
    assert.current_line("hoge")
  end)
end)

describe("searcho.next_match()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the next match in search mode", function()
    helper.set_lines([[

target1
target2
target3
]])
    searcho.forward("target")
    searcho.next_match()
    searcho.finish()

    assert.current_line("target2")
  end)

  it("moves cursor to the next match even if searchforward==0 in search mode", function()
    helper.set_lines([[
target1

target2

target3
]])
    vim.cmd.normal({ args = { "j" }, bang = true })

    searcho.backward("target")
    searcho.next_match()
    searcho.finish()

    assert.current_line("target2")
  end)

  it("does nothing if there is no match", function()
    helper.set_lines([[
no
]])
    searcho.forward("target")
    searcho.next_match()
    searcho.finish()

    assert.current_line("no")
  end)
end)

describe("searcho.previous_match()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the previous match in search mode", function()
    helper.set_lines([[
target1

target2

target3
]])
    vim.cmd.normal({ args = { "j" }, bang = true })

    searcho.forward("target")
    searcho.previous_match()
    searcho.finish()

    assert.current_line("target1")
  end)

  it("moves cursor to the previous match even if searchforward==0 in search mode", function()
    helper.set_lines([[
target0

target1

target2

]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    searcho.backward("target")
    searcho.previous_match()
    searcho.finish()

    assert.current_line("target1")
  end)

  it("does nothing if there is no match", function()
    helper.set_lines([[
no
]])
    searcho.forward("target")
    searcho.previous_match()
    searcho.finish()

    assert.current_line("no")
  end)
end)

describe("searcho.next_page()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the next page's match in search mode", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5

    helper.set_lines([[

target1



target2
]])

    searcho.forward("target")
    searcho.next_page()
    searcho.finish()

    assert.current_line("target2")
  end)

  it("moves cursor to the next page's match even if searchforward==0 in search mode", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5

    helper.set_lines([[
target1




target2
]])
    vim.cmd.normal({ args = { "j" }, bang = true })

    searcho.backward("target")
    searcho.next_page()
    searcho.finish()

    assert.current_line("target2")
  end)

  it("does nothing if there is no match", function()
    helper.set_lines([[
no
]])
    searcho.forward("target")
    searcho.next_page()
    searcho.finish()

    assert.current_line("no")
  end)
end)

describe("searcho.previous_page()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the previous page's match in search mode", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5

    helper.set_lines([[
target1





target2]])
    vim.cmd.normal({ args = { "Gk" }, bang = true })

    searcho.forward("target")
    searcho.previous_page()
    searcho.finish()

    assert.current_line("target1")
  end)

  it("moves cursor to the previous page's match even if searchforward==0 in search mode", function()
    vim.o.display = "lastline" -- workaround for crash
    vim.o.lines = 5

    helper.set_lines([[
target1





target2

]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    searcho.backward("target")
    searcho.previous_page()
    searcho.finish()

    assert.current_line("target1")
  end)

  it("does nothing if there is no match", function()
    helper.set_lines([[
no
]])
    searcho.forward("target")
    searcho.previous_page()
    searcho.finish()

    assert.current_line("no")
  end)
end)

describe("searcho.next()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the next match in normal mode", function()
    helper.set_lines([[

target1
target2
]])
    searcho.forward("target")
    searcho.finish()

    searcho.next({ add_to_history = true })
    helper.cursor_moved()

    assert.current_line("target2")
    assert.exists_message("/target %[2/2%]")
  end)

  it("does not raise error on buf leave", function()
    helper.set_lines([[
target
]])
    searcho.forward("target")
    searcho.finish()

    searcho.next()
    vim.cmd.tabedit()
  end)
end)

describe("searcho.previous()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves cursor to the previous match in normal mode", function()
    helper.set_lines([[
target1

target2
]])
    vim.cmd.normal({ args = { "j" }, bang = true })
    searcho.forward("target")
    searcho.finish()

    vim.cmd.normal({ args = { "0" }, bang = true }) -- HACK
    searcho.previous()
    helper.cursor_moved()

    assert.current_line("target1")
  end)
end)

describe("searcho.forward_history()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("recalls forward history", function()
    helper.set_lines([[
hoge
foo
bar
]])

    searcho.forward()
    helper.input("foo")
    searcho.finish()

    searcho.forward()
    helper.input("bar")
    searcho.finish()
    vim.cmd.normal({ args = { "gg" }, bang = true })

    searcho.forward()
    searcho.backward_history()
    searcho.backward_history()
    searcho.forward_history()
    searcho.finish()

    assert.cursor_word("bar")
  end)
end)

describe("searcho.backward_history()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("recalls backward history", function()
    helper.set_lines([[
hoge
foo
]])

    searcho.forward()
    helper.input("foo")
    searcho.finish()
    vim.cmd.normal({ args = { "gg" }, bang = true })

    searcho.forward()
    searcho.backward_history()
    searcho.finish()

    assert.cursor_word("foo")
  end)

  it("adds search history", function()
    searcho.forward()
    helper.input("recall_history")
    searcho.backward_history()

    assert.equals("recall_history", vim.fn.histget("/"))
  end)
end)

describe("searcho buffer name", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("is the same with default scratch buffer name", function()
    searcho.forward("target")

    assert.buffer_full_name("searcho://[Scratch]")
  end)

  it("suffix is the same with origin buffer name", function()
    vim.api.nvim_buf_set_name(0, "test_buffer_name.lua")

    searcho.forward("target")

    assert.buffer_full_name("searcho://" .. helper.root .. "/test_buffer_name.lua")
  end)
end)

describe("searcho on temporary window", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does not raise error", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local window_id = vim.api.nvim_open_win(bufnr, true, {
      width = 50,
      height = 10,
      relative = "editor",
      row = 10,
      col = 10,
    })
    vim.api.nvim_create_autocmd({ "WinLeave" }, {
      buffer = 0,
      once = true,
      callback = function()
        vim.api.nvim_win_close(window_id, true)
      end,
    })

    searcho.forward("target")
  end)
end)
