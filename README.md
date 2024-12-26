# nvim-binary-clock

This Neovim plugin displays a binary clock in a floating window.

![capture](https://i.ibb.co/MMty8jm/Captura-de-pantalla-2024-12-26-151040.png)

## Installation

You can install this plugin using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use "4DRIAN0RTIZ/binaryclock.nvim"
```

## Configuration

This is a default configuration

```lua
require('binary_clock').setup({
  show = true,
  show_date = false,
  sunday_start_week = false,
  symbols = { on = "█", off = "░" }
})
```
