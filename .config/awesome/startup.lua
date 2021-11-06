local awful = require("awful")

awful.spawn.once(os.getenv("HOME") .. "/bin/blezz", {})
-- awful.spawn.once("kitty", {})
