-- necessary for CLI scripting. IPC means interprocess communication.
require("hs.ipc")
require("keys")
local menuHammer = hs.loadSpoon("MenuHammer")
menuHammer:enter()
-- local emojis = hs.loadSpoon("Emojis")
-- emojis:init()
-- emojis:bindHotkeys({ toggle = { { "cmd", "shift" }, "e" } })
-- hs.alert.show("Hammerspoon config loaded")
hs.notify.show("hammerspoon config reloaded", "", "")
-- This needs to happen pretty late in init. Not sure why.
-- require("focus").initAppWatcher()
