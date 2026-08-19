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
-- hs.hotkey.bind({}, "F10", focus.leader)
hs.hotkey.bind({}, "F11", fuzzball.chooseScript)
hs.hotkey.bind({ "command" }, "space", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "2", fuzzball.chooseScript)
hs.hotkey.bind({ "control" }, "3", snippets.chooseByUIAndType)
hs.hotkey.bind({}, "F12", snippets.chooseByUIAndType)

-- Reload on keyboard layout change. hs.keycodes.map refreshes itself, but
-- hs.hotkey caches keycodes at bind time, so bindings need to be rebuilt.
local lastSourceID = hs.keycodes.currentSourceID()
hs.keycodes.inputSourceChanged(function()
	local sourceID = hs.keycodes.currentSourceID()
	-- the notification also fires for input method changes within a layout
	if sourceID == lastSourceID then
		return
	end
	lastSourceID = sourceID
	-- defer, so we don't tear down the Lua state from inside its own callback
	hs.timer.doAfter(0.5, hs.reload)
end)
