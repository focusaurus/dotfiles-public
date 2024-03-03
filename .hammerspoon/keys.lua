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
hs.hotkey.bind(me2, "up", focus.previousApp)
hs.hotkey.bind(me2, "down", placement.cycle)

-- placement
hs.hotkey.bind(hyper_pl, ".", placement.cycle)

-- fuzzy prompts
hs.hotkey.bind({ "shift" }, "F10", focus.leader)
hs.hotkey.bind({}, "F11", fuzzball.chooseScript)
hs.hotkey.bind({ "command" }, "space", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "2", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "3", snippets.chooseByUIAndType)
hs.hotkey.bind({}, "F12", snippets.chooseByUIAndType)
