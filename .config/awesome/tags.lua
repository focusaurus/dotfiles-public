local awful = require('awful')
local module = {}
function module.select(tag_name)
  local t = awful.tag.find_by_name(awful.screen.focused(), tag_name)
  if not t then return end
  t:view_only()
end

return module
