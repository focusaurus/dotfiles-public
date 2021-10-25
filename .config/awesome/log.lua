local module = {}

local gears_debug = require("gears.debug")

-- This writes to ~/.xsession-errors
function module.log(message)
  the_type = type(message)
  -- gears_debug.print_warning("type: " .. the_type)
  if the_type == "nil" then
    gears_debug.print_warning("log(nil)")
  elseif the_type == "boolean" then
    gears_debug.print_warning(tostring(message))
  elseif the_type == "string" or the_type == "number" or the_type == "boolean" then
    gears_debug.print_warning(message)
  elseif the_type == "table" then
    gears_debug.print_warning(gears_debug.dump_return(message))
  end
end

return module
