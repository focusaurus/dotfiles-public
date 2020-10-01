local log = hs.logger.new("init", "debug")
-- required for the "hs" command line utility to work
require("hs.ipc")

----- hammerspoon debugging and exploration -----
local function chromeTabs()
  local menuItems = hs.application.frontmostApplication():getMenuItems()
  local tabTitles = ""
  for _, menuItem in pairs(menuItems) do
    -- hs.alert("menu: " .. menuItem.AXTitle)
    if menuItem.AXTitle == "Tab" then
     log.d(hs.inspect(menuItem))
     for _, subItem in pairs(menuItem.AXChildren[1]) do
       tabTitles = tabTitles .. subItem.AXTitle .. "\n"
     end
    end
  end
  hs.alert(tabTitles)
end

local function notification()
  hs.notify.show("Hello, world!", "two", "three")
end

local function runningApplications()
  local apps = hs.application.runningApplications()

  for _, app in pairs(apps) do
    log.d(app:name())
  end
end

hs.hotkey.bind({"control"}, "2", runningApplications);
