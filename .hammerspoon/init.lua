-- Swap in dmgerman's rewritten hs.window.filter (must run before anything uses it)
-- https://github.com/dmgerman/hammerspoon/blob/new-window-filter/extensions/window/window_filter_new.lua
-- To revert to the stock filter, comment out these lines.
local newWindowFilter = dofile(hs.configdir .. "/window_filter_new.lua")
package.loaded["hs.window.filter"] = newWindowFilter
hs.window.filter = newWindowFilter

require("keys")
require("hammerspoon")
local menuHammer = hs.loadSpoon("MenuHammer")
menuHammer:enter()
-- local emojis = hs.loadSpoon("Emojis")
-- emojis:init()
-- emojis:bindHotkeys({ toggle = { { "cmd", "shift" }, "e" } })
-- hs.alert.show("Hammerspoon config loaded")
hs.notify.show("hammerspoon config reloaded", "", "")
-- This needs to happen pretty late in init. Not sure why.
-- require("focus").initAppWatcher()
