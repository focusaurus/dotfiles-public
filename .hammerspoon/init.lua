local log = hs.logger.new("init", "debug")

require("autotype")
require("browser-tabs")
require("hammerspoon")
require("keys")
require("screenshots")
require("reload")
require("window-tabs")
hs.alert.show("Hammerspoon config loaded")

menuHammer = hs.loadSpoon("MenuHammer")
menuHammer:enter()
-- This needs to happen pretty late in init. Not sure why.
require("focus").initAppWatcher()
