local module = {}
local log = hs.logger.new("reload", "debug")
local reloadEnabled = false

----- hammerspoon config reloading -----
function module.reloadConfig(files)
  log.d("reloadConfig")
    local doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload and reloadEnabled then
        hs.reload()
    end
end

function module.enable()
 reloadEnabled = true
 -- If we are enabling this, assume we also want an immediate reload
 module.reloadConfig()
end

function module.disable()
 reloadEnabled = false
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", module.reloadConfig):start()

return module
