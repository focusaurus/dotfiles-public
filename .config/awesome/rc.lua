-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require("errors")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.get().font = "Inconsolata 16"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {awful.layout.suit.floating, awful.layout.suit.max}
require("focus")
require("keys")
require("placement")
require("wibar")
require("rules")
require("signals")
