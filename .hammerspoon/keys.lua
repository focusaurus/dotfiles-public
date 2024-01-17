local appNav = require("app-nav")
local focus = require("focus")
local fuzzball = require("fuzzball")
-- local journal = require("journal")
local placement = require("placement")
local snippets = require("snippets")
-- local sound = require("sound")

local hyper_pl = { "command", "shift" }
local me1 = { "command", "shift" }
local me2 = { "command", "control" }

-- dev
hs.hotkey.bind({}, "f1", appNav.right)

-- app nav
hs.hotkey.bind(me1, "left", appNav.left)
hs.hotkey.bind(me1, "down", appNav.down)
hs.hotkey.bind(me1, "up", appNav.up)
hs.hotkey.bind(me1, "right", appNav.right)

-- window manager nav
hs.hotkey.bind(me2, "up", focus.previous)
hs.hotkey.bind(me2, "down", placement.cycle)

-- placement
hs.hotkey.bind(hyper_pl, ".", placement.cycle)
-- for compat until kmonad on mac is fully working
-- hs.hotkey.bind({"option"}, ".", placement.cycle)

-- fuzzy prompts
hs.hotkey.bind({ "shift" }, "F10", focus.leader)
hs.hotkey.bind({}, "F11", fuzzball.chooseScript)
hs.hotkey.bind({ "command" }, "space", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "2", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "3", snippets.chooseByUIAndType)
hs.hotkey.bind({}, "F12", snippets.chooseByUIAndType)

-- journal
---- hs.hotkey.bind({}, "f9", journal.appendByDialog)
-- hs.hotkey.bind({"shift"}, "f9", journal.appendByDialogStandup)

-- focus
-- hs.hotkey.bind({}, "f1", focus.browser)
-- hs.hotkey.bind({"shift"}, "f1", focus.email)
-- hs.hotkey.bind({}, "f2", focus.code)
-- hs.hotkey.bind({}, "f3", focus.terminal)
-- hs.hotkey.bind({}, "f4", focus.emacs)
-- hs.hotkey.bind({}, "f5", focus.slackOrZoom)
-- local switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
-- hs.hotkey.bind(hyper_pl, "e", focus.previous)
-- for compat until kmonad on mac is fully working
-- hs.hotkey.bind({"option"}, "e", focus.previous)
-- hs.hotkey.bind(hyper_pl, "e", switcher.nextWindow)
-- for compat until kmonad on mac is fully working
-- hs.hotkey.bind({"option"}, "e", switcher.nextWindow)
-- hs.hotkey.bind({}, "f6", focus.slackOrZoom)
-- hs.hotkey.bind({}, "f7", focus.calendar)
-- hs.hotkey.bind({}, "f8", focus.music)
-- hs.hotkey.bind({}, "f2", focus.calendar2)

-- sound
-- hs.hotkey.bind({}, "f10", sound.toggleMute)
-- hs.hotkey.bind({}, "f11", sound.volumeDown)
-- hs.hotkey.bind({}, "f12", sound.volumeUp)
