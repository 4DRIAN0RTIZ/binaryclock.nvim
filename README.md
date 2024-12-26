# nvim-binary-clock

This Neovim plugin displays a binary clock in a floating window.

## Installation

You can install this plugin using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  '4DRIAN0RTIZ/binaryclock.nvim',
  config = function()
    require('binary_clock').setup({
      win_width = 12,
      win_height = 10,
      border = 'rounded',
      symbols = { on = "█", off = "░" }
    })
  end
}
```
