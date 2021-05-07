local log = hs.logger.new("init", "debug")

require("autotype")
require("browser-tabs")
require("hammerspoon")
require("keys")
require("screenshots")
hs.alert.show("Hammerspoon config loaded")

menuHammer = hs.loadSpoon("MenuHammer")
menuHammer:enter()

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
