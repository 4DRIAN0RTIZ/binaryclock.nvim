local M = {}
local win_id = nil
local timer = nil
local utils = require('utils')

M.config = {
  show = true,
  show_date = false,
  sunday_start_week = false,
  symbols = {
    on = "█",
    off = "░",
  },
}

function M.setup(options)
  M.config = vim.tbl_deep_extend("force", M.config, options or {})

  if win_id and vim.api.nvim_win_is_valid(win_id) then
    apply_config()
  end

  if M.config.show and not win_id then
    M.show_binary_clock(M.config.show_date)
  elseif M.config.show and win_id then
    M.close_binary_clock()
  end
end

local function apply_config()
  if not win_id or not vim.api.nvim_win_is_valid(win_id) then return end
end

local function get_time()
  return os.date("*t")
end

local function adjust_weekday(wday)
  return M.config.sunday_start_week and wday or (wday == 1 and 7 or wday - 1)
end

local function get_binary_time()
  local time = get_time()
  local binary_time = {
    hour = utils.binary_to_on_off(utils.decimal_to_binary(time.hour, 5), M.config.symbols),
    minute = utils.binary_to_on_off(utils.decimal_to_binary(time.min, 6), M.config.symbols),
    weekday = utils.binary_to_on_off(utils.decimal_to_binary(adjust_weekday(time.wday), 3), M.config.symbols),
    day = utils.binary_to_on_off(utils.decimal_to_binary(time.day, 5), M.config.symbols),
    month = utils.binary_to_on_off(utils.decimal_to_binary(time.month, 4), M.config.symbols),
  }
  return binary_time
end

local function update_binary_clock()
  if not win_id or not vim.api.nvim_win_is_valid(win_id) then return end

  local binary_time = get_binary_time()
  local lines = {
    binary_time.hour,
    "",
    binary_time.minute,
    "",
    binary_time.weekday,
    "",
    binary_time.day,
    "",
    binary_time.month,
  }

  local buf = vim.api.nvim_win_get_buf(win_id)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function update_window_position()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = 12
    local win_height = 10
    local row = height - win_height - 3
    local col = width - win_width - 1
    vim.api.nvim_win_set_config(win_id, {
      relative = 'editor',
      width = win_width,
      height = win_height,
      row = row,
      col = col,
    })
  end
end

local function start_timer()
  if timer then
    timer:stop()
    timer:close()
  end
  timer = vim.loop.new_timer()

  local current_time = os.date("*t")
  local delay = (60 - current_time.sec) * 1000

  timer:start(delay, 60000, vim.schedule_wrap(update_binary_clock))
end

function M.show_binary_clock(show_date)
  if win_id and vim.api.nvim_win_is_valid(win_id) then return end

  local binary_time = get_binary_time()
  local lines = {
    binary_time.hour,
    "",
    binary_time.minute,
  }

  if show_date then
    table.insert(lines, "")
    table.insert(lines, binary_time.weekday)
    table.insert(lines, "")
    table.insert(lines, binary_time.day)
    table.insert(lines, "")
    table.insert(lines, binary_time.month)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  local win_width = 12
  local win_height = show_date and 10 or 4
  local row = height - win_height - 3
  local col = width - win_width - 1

  win_id = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  apply_config()
  start_timer()

  vim.cmd([[
    augroup BinaryClock
      autocmd!
      autocmd VimResized * lua require('binary_clock').update_window_position()
    augroup END
  ]])
end

function M.close_binary_clock()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
    win_id = nil
  end
end

function M.toggle_binary_clock()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    M.close_binary_clock()
  else
    M.show_binary_clock()
  end
end

M.update_window_position = update_window_position

function M.handle_subcommand(subcommand)
  local args = vim.split(subcommand, " ")
  local cmd = args[1]
  local param = args[2]

  if cmd == "show" then
    M.show_binary_clock(M.config.show_date)
    vim.notify("BinaryClock is now shown", vim.log.levels.INFO)
  elseif cmd == "hide" then
    M.close_binary_clock()
    vim.notify("BinaryClock is now hidden", vim.log.levels.INFO)
  elseif cmd == "toggle" then
    M.toggle_binary_clock()
    vim.notify("BinaryClock toggled", vim.log.levels.INFO)
  elseif cmd == "sunday_start_week" then
    if param == "true" or param == "false" then
      M.config.sunday_start_week = (param == "true")
      if win_id and vim.api.nvim_win_is_valid(win_id) then
        M.close_binary_clock()
        M.show_binary_clock(M.config.show_date)
      end
      vim.notify("Sunday start week is now " .. tostring(M.config.sunday_start_week), vim.log.levels.INFO)
    else
      vim.notify("Invalid parameter for sunday_start_week. Use true or false.", vim.log.levels.ERROR)
    end
  elseif cmd == "show_date" then
    if param == "true" or param == "false" then
      M.config.show_date = (param == "true")
      if win_id and vim.api.nvim_win_is_valid(win_id) then
        M.close_binary_clock()
        M.show_binary_clock(M.config.show_date)
      end
      vim.notify("Show date is now " .. tostring(M.config.show_date), vim.log.levels.INFO)
    else
      vim.notify("Invalid parameter for show_date. Use true or false.", vim.log.levels.ERROR)
    end
  else
    vim.notify("Subcommand not recognized: " .. cmd, vim.log.levels.ERROR)
  end
end

return M
