local helper = require "test.helper"
local assert = helper.assert
local command = helper.command

describe('searcho', function ()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it('can search forward', function ()
    helper.set_lines([[
hoge
foo]])

    local cmd = vim.fn["searcho#do"]("forward") .. "foo"
    command(cmd)

    assert.current_line("foo")
  end)

  it('can search backward', function ()
    helper.set_lines([[
hoge

foo]])
    command("normal! G")

    local cmd = vim.fn["searcho#do"]("backward") .. "hoge"
    command(cmd)

    assert.current_line("hoge")
  end)

  it('can restore keymaps', function ()
    helper.set_lines([[
a
a]])

    command("cnoremap <buffer> a c")

    require("searcho/search").keymaps = {
      {
        lhs = "a",
        rhs = "b",
        noremap = true
      },
      {
        lhs = "a",
        rhs = "b",
        noremap = true
      }
    }

    local cmd = vim.fn["searcho#do"]("forward") .. "a"
    command(cmd)
    command("doautocmd CmdlineLeave")

    assert.has_keymap("a", "c")
  end)

end)
