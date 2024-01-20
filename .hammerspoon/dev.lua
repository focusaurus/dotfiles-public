local module = {}
local log = hs.logger.new("app-nav", "debug")
local focus = require("focus")
local placement = require("placement")

local function startsWith(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

local function hasTitlePrefix(prefix)
  return function(window)
    return startsWith(window:title(), prefix)
  end
end

local prefixFilter = hs.window.filter.new(hasTitlePrefix("google meet:"))
function module.dev1()
  windows = prefixFilter:getWindows(hs.window.filter.sortByFocusedLast)

  hs.alert.show("dev1 called. " .. tostring(#windows))
  focus.obsidian()
  placement.right()
  local meetWindow = windows[1]
  -- See Hammerspoon layout documentation for more info on this
  if meetWindow == nil then
    log.d("Did not find google meet window. Abort")
    return
  end
  meetWindow:focus()
  placement.left()
  -- local mainScreen = hs.screen({ x = 0, y = 0 })
  -- hs.layout.apply({
  --   { meetWindow, nil, mainScreen, hs.layout.left50, nil, nil },
  --   { "Obsidian", nil, mainScreen, hs.layout.right50, nil, nil },
  -- })
end

return module
