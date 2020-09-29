local fuzzball = require("fuzzball")
local appNav = require("app-nav")
local journal = require("journal")
local snippets = require("snippets")
local placement = require("placement")

local hyper_pl = {"command", "option"}

hs.hotkey.bind(hyper_pl, "o", appNav.left)
hs.hotkey.bind(hyper_pl, "e", appNav.up)
hs.hotkey.bind(hyper_pl, "u", appNav.right)
hs.hotkey.bind(hyper_pl, "j", appNav.down)

-- for compat until kmonad on mac is fully working
hs.hotkey.bind({"option"}, "o", appNav.left)
hs.hotkey.bind({"option"}, "e", appNav.up)
hs.hotkey.bind({"option"}, "u", appNav.right)
hs.hotkey.bind({"option"}, "j", appNav.down)

hs.hotkey.bind({"command"}, "space", fuzzball.chooseScript)

hs.hotkey.bind({}, "f9", journal.appendByDialog)
hs.hotkey.bind({"shift"}, "f9", journal.appendByDialogStandup)

hs.hotkey.bind({"control"}, ",", snippets.chooseByUIAndType)

hs.hotkey.bind(hyper_pl, "c", placement.cycle)
hs.hotkey.bind({"option"}, "c", placement.cycle)
-- for compat until kmonad on mac is fully working
hs.hotkey.bind({"option"}, "c", placement.cycle)
