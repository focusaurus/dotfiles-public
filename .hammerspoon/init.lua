local log = hs.logger.new("init", "debug")

require("app-nav")
require("autotype")
require("fkeys")
require("fuzzball")
require("journal")
require("screenshots")
require("snippets")
require("sound")
require("window-management")

----- hammerspoon debugging -----
hs.hotkey.bind({"control"}, "2", function()
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
end)

----- hammerspoon config reloading -----
function reloadConfig(files)
  log.d("reloadConfig")
    local doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config reloaded")
