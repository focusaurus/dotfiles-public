local log = hs.logger.new("init", "debug")

require("autotype")
require("browser-tabs")
require("hammerspoon")
require("keys")
require("screenshots")
-- require("reload")
require("window-tabs")
hs.alert.show("Hammerspoon config loaded")

menuHammer = hs.loadSpoon("MenuHammer")
menuHammer:enter()
