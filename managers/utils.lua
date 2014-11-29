---------------------------------
-- round(num, decimalPlaces)
-- Rounds the number to the desired number of decimal places
--------------------------------
function round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult 
end

  