-------------------------------
-- DOCUMENTATION : https://docs.jumpon-studios.com/
--------------------------------

Config = {} --Global configuration table
Lang = {}   --Global language table

function __(name)
  return Lang[name] and Lang[name] .. "" or ("#" .. name)
end