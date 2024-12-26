local binary_clock = require('binary_clock')

vim.api.nvim_create_user_command('BinaryClock', function(opts)
  binary_clock.handle_subcommand(opts.args)
end, {
  nargs = 1,
  complete = function(_, _, _)
    return { "show", "hide", "toggle", "sunday_start_week", "show_date" }
  end
})
