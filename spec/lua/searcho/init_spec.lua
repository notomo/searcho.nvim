local helper = require("searcho.test.helper")
local searcho = helper.require("searcho")

describe("searcho.word_forward()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("stays in the cursor word, then start forward search", function()
    helper.set_lines([[
 target 1

target 2

target 3
]])
    vim.cmd.normal({ args = { "l" }, bang = true })

    searcho.word_forward()
    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "ntx", true)

    assert.current_line(" target 1")

    vim.cmd.normal({ args = { "n" }, bang = true })

    assert.current_line("target 2")
  end)

  it("can use with empty", function()
    vim.fn.setreg("/", ".*")
    searcho.word_forward()
    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "ntx", true)
  end)
end)

describe("searcho.backward_word()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("stays in the cursor word, then start backward search", function()
    helper.set_lines([[
target 1

target 2

target 3
]])

    searcho.word_backward()
    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "ntx", true)

    assert.current_line("target 1")

    vim.cmd.normal({ args = { "N" }, bang = true })

    assert.current_line("target 2")
  end)

  it("can use with empty", function()
    vim.fn.setreg("/", ".*")
    searcho.word_forward()
    vim.api.nvim_feedkeys(vim.keycode("<CR>"), "ntx", true)
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

    local key = "n"
    vim.keymap.set("n", key, function()
      return searcho.normal("n")
    end, { buffer = true, expr = true })
    searcho.normal("n")
    vim.api.nvim_feedkeys(key, "rx", true)
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

    searcho.word_forward()
    vim.api.nvim_feedkeys(vim.keycode("<Space>"), "tx", true)

    vim.api.nvim_feedkeys(vim.keycode(":<Space>"), "tx", true)

    assert.equal(1, count)
  end)
end)
