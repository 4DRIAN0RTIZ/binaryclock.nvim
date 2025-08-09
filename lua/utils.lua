local M = {}

function M.decimal_to_binary(number, bits)
  local binary_table = {}
  for i = bits - 1, 0, -1 do
    binary_table[#binary_table + 1] = math.floor(number / (2 ^ i)) % 2
  end
  return table.concat(binary_table)
end

function M.binary_to_on_off(binary, symbols)
  symbols = symbols or { on = "█", off = "░" }
  return (binary:gsub(".", { ["1"] = symbols.on .. " ", ["0"] = symbols.off .. " " }))
end

return M