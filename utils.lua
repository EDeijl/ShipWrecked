function round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult 
end

  