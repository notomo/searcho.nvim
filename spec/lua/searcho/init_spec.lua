local helper = require("searcho.test.helper")
local searcho = helper.require("searcho")
local assert = require("assertlib").typed(assert)

describe("searcho.forward()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can stay in the cursor word, then start forward search", function()
    helper.set_lines([[
 target 1

target 2

target 3
]])
    vim.cmd.normal({ args = { "l" }, bang = true })

    helper.execute_as_expr(function()
      local word = vim.fn.expand("<cword>")
      return searcho.forward() .. word .. vim.keycode("<CR>")
    end)

    assert.current_line(" target 1")

    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("target 2")
  end)

  it("can stay in the cursor word even if cursor is in the top of the buffer", function()
    helper.set_lines([[
target 1

target 2

target 3
]])
    vim.cmd.normal({ args = { "l" }, bang = true })

    helper.execute_as_expr(function()
      local word = vim.fn.expand("<cword>")
      return searcho.forward() .. word .. vim.keycode("<CR>")
    end)

    assert.current_line("target 1")

    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("target 2")
  end)
end)

describe("searcho.backward()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can stay in the cursor word, then start backward search", function()
    helper.set_lines([[
target 1

target 2

target 3
]])

    helper.execute_as_expr(function()
      local word = vim.fn.expand("<cword>")
      return searcho.backward() .. word .. vim.keycode("<CR>")
    end)

    assert.current_line("target 1")

    vim.cmd.normal({ args = { "N" }, bang = true })

    assert.current_line("target 2")
  end)

  it("can stay in the cursor word even if cursor is in the bottom of the buffer", function()
    helper.set_lines([[
1 target

2 target

3 target]])
    vim.cmd.normal({ args = { "G$" }, bang = true })

    helper.execute_as_expr(function()
      local word = vim.fn.expand("<cword>")
      return searcho.backward() .. word .. vim.keycode("<CR>")
    end)

    assert.current_line("3 target")

    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("2 target")
  end)
end)

describe("searcho.normal()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can use with n", function()
    helper.set_lines([[

target1
target2
]])
    vim.fn.setreg("/", "target")

    helper.execute_as_expr(function()
      return searcho.normal("n")
    end)
    helper.cursor_moved()

    assert.current_line("target1")
  end)
end)

describe("searcho.setup_keymaps()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("setup keymaps for command line type is search", function()
    helper.set_lines([[
target
]])

    local count = 0
    searcho.setup_keymaps(function(vim)
      vim.keymap.set("c", "<Space>", function()
        count = count + 1
      end, { buffer = true })
    end)

    vim.api.nvim_feedkeys("/", "t", true)

    vim.api.nvim_feedkeys(vim.keycode("<Space>"), "tx", true)

    vim.api.nvim_feedkeys(vim.keycode(":<Space>"), "tx", true)

    assert.equal(1, count)
  end)
end)
