# searcho.nvim

## Example

```lua
vim.keymap.set({ "n", "x" }, "*", function()
  local pattern = [[\v]] .. vim.fn.expand("<cword>")
  return require("searcho").forward() .. pattern
end, { expr = true })
vim.keymap.set({ "n", "x" }, "#", function()
  local pattern = [[\v]] .. vim.fn.expand("<cword>")
  return require("searcho").backward() .. pattern
end, { expr = true })

vim.keymap.set({ "n", "x" }, "n", function()
  return require("searcho").normal("n")
end, { expr = true })
vim.keymap.set({ "n", "x" }, "N", function()
  return require("searcho").normal("N")
end, { expr = true })

require("searcho").setup_keymaps(function(vim)
  vim.keymap.set("c", "<Tab>", [[<C-g>]], { buffer = true })
  vim.keymap.set("c", "<S-Tab>", [[<C-t>]], { buffer = true })
  vim.keymap.set("c", "<Space>", [[<CR>]], { buffer = true })
end)
```