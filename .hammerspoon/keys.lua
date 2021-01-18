local appNav = require("app-nav")
local focus = require("focus")
local fuzzball = require("fuzzball")
local journal = require("journal")
local placement = require("placement")
local snippets = require("snippets")
local sound = require("sound")

local hyper_pl = {"option", "command"}

-- app nav
hs.hotkey.bind(hyper_pl, "o", appNav.left)
-- hs.hotkey.bind(hyper_pl, "t", appNav.up)
hs.hotkey.bind(hyper_pl, "u", appNav.right)
hs.hotkey.bind(hyper_pl, "j", appNav.down)

-- for compat until kmonad on mac is fully working
hs.hotkey.bind({"option"}, "o", appNav.left)
-- hs.hotkey.bind({"option"}, "t", appNav.up)
hs.hotkey.bind({"option"}, "u", appNav.right)
hs.hotkey.bind({"option"}, "j", appNav.down)

-- Disabled temporarily due to conflict with org-mode
-- hs.hotkey.bind({"option"}, "j", appNav.down)

-- placement
hs.hotkey.bind(hyper_pl, ".", placement.cycle)
-- for compat until kmonad on mac is fully working
hs.hotkey.bind({"option"}, ".", placement.cycle)

-- fuzzy prompts
hs.hotkey.bind({"command"}, "space", fuzzball.chooseScript)
hs.hotkey.bind({}, "F11", fuzzball.chooseScript)
hs.hotkey.bind({"control"}, "3", snippets.chooseByUIAndType)
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
switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces

-- hs.hotkey.bind(hyper_pl, "e", focus.previous)
-- for compat until kmonad on mac is fully working
-- hs.hotkey.bind({"option"}, "e", focus.previous)
hs.hotkey.bind(hyper_pl, "e", switcher.nextWindow)
-- for compat until kmonad on mac is fully working
hs.hotkey.bind({"option"}, "e", switcher.nextWindow)
-- hs.hotkey.bind({}, "f6", focus.slackOrZoom)
-- hs.hotkey.bind({}, "f7", focus.calendar)
-- hs.hotkey.bind({}, "f8", focus.music)

-- sound
-- hs.hotkey.bind({}, "f10", sound.toggleMute)
-- hs.hotkey.bind({}, "f11", sound.volumeDown)
-- hs.hotkey.bind({}, "f12", sound.volumeUp)
