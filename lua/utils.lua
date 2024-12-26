local function decimal_to_binary(number, bits)
  local binary = ""
  while bits > 0 do
    local remainder = number % 2
    binary = remainder .. binary
    number = math.floor(number / 2)
    bits = bits - 1
  end
  return binary
end

local function binary_to_on_off(binary, symbols)
  symbols = symbols or { on = "█", off = "░" }
  return binary:gsub("1", symbols.on .. " "):gsub("0", symbols.off .. " ")
end

return {
  decimal_to_binary = decimal_to_binary,
  binary_to_on_off = binary_to_on_off,
}
