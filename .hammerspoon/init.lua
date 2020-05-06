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
  local windows = hs.application.frontmostApplication():visibleWindows()
  hs.alert("frontmost app has " .. #windows .. " windows open")
  if #windows > 1 then
  -- for i,v in ipairs(windows) do 
  end
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
