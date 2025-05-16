local appNav = require("app-nav")
local focus = require("focus")
local mpd = require("mpd")
local fuzzball = require("fuzzball")
local journal = require("journal")
local placement = require("placement")
local snippets = require("snippets")
local sound = require("sound")
local dev = require("dev")

local function a(it, i)
	it[#it + 1] = i
end

--------------------------------------- General Config ---------------------------------------------

-- If enabled, the menus will appear over full screen applications.
-- However, the Hammerspoon dock icon will also be disabled (required for fullscreen).
menuShowInFullscreen = false

-- If enabled, a menu bar item will appear that shows what menu is currently being displayed or
-- 'idle' if no menu is open.
showMenuBarItem = false

-- The number of seconds that a hotkey alert will stay on screen.
-- 0 = alerts are disabled.
hs.hotkey.alertDuration = 0

-- Show no titles for Hammerspoon windows.
hs.hints.showTitleThresh = 0

-- Disable animations
hs.window.animationDuration = 0

----------------------------------------- Menu options ---------------------------------------------

-- The number of columns to display in the menus.  Setting this too high or too low will
-- probably have odd results.
menuNumberOfColumns = 7

-- The minimum number of rows to show in menus
menuMinNumberOfRows = 4

-- The height of menu rows in pixels
menuRowHeight = 22

-- The padding to apply to each side of the menu
menuOuterPadding = 20

----------------------------------------- Font options ---------------------------------------------
menuItemFont = "Hack Nerd Font"
menuItemFontSize = 16
menuItemTextAlign = "left"

---------------------------------------- Color options ---------------------------------------------
local defaultColors = { background = "#3d95d6", text = "#0a1122" }
menuItemColors = {
	default = defaultColors,
	exit = defaultColors,
	back = defaultColors,
	submenu = defaultColors,
	navigation = defaultColors,
	empty = defaultColors,
	action = defaultColors,
	menuBarActive = defaultColors,
	menuBarIdle = defaultColors,
	display = defaultColors,
}

----------------------------------------------------------------------------------------------------
-------------------------------------- Menu bar options --------------------------------------------
----------------------------------------------------------------------------------------------------

-- Key bindings

-- The hotkey that will enable/disable MenuHammer
menuHammerToggleKey = { { "cmd", "shift", "ctrl" }, "Q" }

-- Menu Prefixes
menuItemPrefix = {
	action = "↩",
	submenu = "→",
	back = "←",
	exit = "x",
	navigation = "↩",
	-- navigation = '⎋',
	empty = "",
	display = "",
}

-- Menu item separator
menuKeyItemSeparator = ": "

----------------------------------------------------------------------------------------------------
--------------------------------------- Default Menus ----------------------------------------------
----------------------------------------------------------------------------------------------------

local noMod = ""

-- Menus
local menuNameMain = "Main"

local menuNameFloatHealth = "Float Health"
local i = {}
a(i, { cons.cat.action, noMod, "Y", "Playwright (Chromium)", { { cons.act.launcher, "Chromium" } } })
a(i, { cons.cat.action, noMod, "z", "zed", { { cons.act.launcher, "Zed" } } })
local menuFloatHealth = { menuItems = i, parentMenu = menuNameMain }

local menuNameHammerspoon = "Hammerspoon"
local function hsManual()
	hs.doc.hsdocs.forceExternalBrowser(true)
	hs.doc.hsdocs.moduleEntitiesInSidebar(true)
	hs.doc.hsdocs.help()
end
local i = {}
a(i, { cons.cat.action, noMod, "C", "Hammerspoon Console", { { cons.act.func, hs.toggleConsole } } })
a(i, { cons.cat.action, noMod, "H", "Hammerspoon Manual", { { cons.act.func, hsManual } } })
a(i, { cons.cat.action, noMod, "R", "Reload Hammerspoon", { { cons.act.func, hs.reload } } })
a(i, { cons.cat.action, noMod, "Q", "Quit Hammerspoon", { { cons.act.func, os.exit } } })
local menuHammerspoon = { menuItems = i, parentMenu = menuNameMain }

local menuNameHelp = "Help"
local i = {}
a(i, { cons.cat.action, noMod, "H", "Hammerspoon Manual", { { cons.act.func, hsManual } } })
a(i, {
	cons.cat.action,
	"",
	"M",
	"MenuHammer Documentation",
	{ { cons.act.openurl, "https://github.com/FryJay/MenuHammer" } },
})
local menuHelp = { menuItems = i, parentMenu = menuNameMain }

local menuNameJournal = "Journal"
local i = {}
a(i, { cons.cat.action, noMod, "j", "Journal", { { cons.act.func, journal.appendPrompt } } })
a(i, { cons.cat.action, noMod, "c", "Check In", { { cons.act.func, journal.appendPromptCheckIn } } })
a(i, { cons.cat.action, noMod, "t", "Task", { { cons.act.func, journal.appendPromptTask } } })
a(i, { cons.cat.action, noMod, "v", "vim", { { cons.act.func, journal.appendVim } } })
local menuJournal = { menuItems = i, parentMenu = menuNameMain }

local menuNameLayout = "Layout (Placement)"
local i = {}
a(i, { cons.cat.action, noMod, "l", "Left", { { cons.act.func, placement.left } } })
a(i, { cons.cat.action, noMod, "r", "Right", { { cons.act.func, placement.right } } })
a(i, { cons.cat.action, noMod, "m", "Max", { { cons.act.func, placement.maximize } } })
local menuLayout = { menuItems = i, parentMenu = menuNameMain }

local menuNameLearnLua = "Learn Lua"
local i = {}
a(i, { cons.cat.action, noMod, "a", "Aggregate", { { cons.act.func, journal.appendPrompt } } })
a(i, { cons.cat.action, noMod, "b", "Burn", { { cons.act.func, journal.appendPrompt } } })
local menuLearnLua = { menuItems = i, parentMenu = menuNameMain }

local menuNameMusic = "mUsic"
local i = {}
a(i, { cons.cat.action, noMod, "space", "Toggle", { { cons.act.func, mpd.toggle } } })
a(i, { cons.cat.action, noMod, "t", "Toggle", { { cons.act.func, mpd.toggle } } })
a(i, { cons.cat.action, noMod, "p", "Play", { { cons.act.func, mpd.play } } })
a(i, { cons.cat.action, noMod, "u", "Pause", { { cons.act.func, mpd.pause } } })
local menuMusic = { menuItems = i, parentMenu = menuNameMain }

-- Menu: Personal
local menuNamePersonal = "Personal"
local i = {}
a(i, { cons.cat.action, noMod, "B", "Bambu Studio", { { cons.act.launcher, "BambuStudio" } } })
a(i, { cons.cat.action, noMod, "F", "Fusion", { { cons.act.launcher, "Fusion" } } })
a(i, { cons.cat.action, noMod, "P", "PrusaSlicer", { { cons.act.launcher, "PrusaSlicer" } } })
local menuPersonal = { menuItems = i, parentMenu = menuNameMain }

local menuNameVolume = "Volume"
a(i, { cons.cat.action, noMod, "1", "10%", { {
	cons.act.func,
	function()
		sound.setVolume(10)
	end,
} } })
a(i, { cons.cat.action, noMod, "2", "20%", { {
	cons.act.func,
	function()
		sound.setVolume(20)
	end,
} } })
a(i, { cons.cat.action, noMod, "3", "30%", { {
	cons.act.func,
	function()
		sound.setVolume(30)
	end,
} } })
a(i, { cons.cat.action, noMod, "t", "30%", { {
	cons.act.func,
	function()
		sound.setVolume(30)
	end,
} } })
a(i, { cons.cat.action, noMod, "4", "50%", { {
	cons.act.func,
	function()
		sound.setVolume(40)
	end,
} } })
a(i, { cons.cat.action, noMod, "5", "50%", { {
	cons.act.func,
	function()
		sound.setVolume(50)
	end,
} } })
a(i, { cons.cat.action, noMod, "f", "50%", { {
	cons.act.func,
	function()
		sound.setVolume(50)
	end,
} } })
a(i, { cons.cat.action, noMod, "6", "60%", { {
	cons.act.func,
	function()
		sound.setVolume(60)
	end,
} } })
a(i, { cons.cat.action, noMod, "7", "70%", { {
	cons.act.func,
	function()
		sound.setVolume(70)
	end,
} } })
a(i, { cons.cat.action, noMod, "s", "70%", { {
	cons.act.func,
	function()
		sound.setVolume(70)
	end,
} } })
a(i, { cons.cat.action, noMod, "8", "80%", { {
	cons.act.func,
	function()
		sound.setVolume(80)
	end,
} } })
a(i, { cons.cat.action, noMod, "e", "80%", { {
	cons.act.func,
	function()
		sound.setVolume(80)
	end,
} } })
a(i, { cons.cat.action, noMod, "9", "90%", { {
	cons.act.func,
	function()
		sound.setVolume(90)
	end,
} } })
a(i, { cons.cat.action, noMod, "n", "90%", { {
	cons.act.func,
	function()
		sound.setVolume(90)
	end,
} } })
a(i, { cons.cat.action, noMod, "h", "100%", { {
	cons.act.func,
	function()
		sound.setVolume(100)
	end,
} } })
local menuVolume = { menuItems = i, parentMenu = menuNameMain }

local i = {}
a(i, { cons.cat.action, noMod, "a", "API (Postman)", { { cons.act.launcher, "Postman" } } })
a(i, { cons.cat.action, noMod, "b", "Browser", { { cons.act.func, focus.browser } } })
a(i, { cons.cat.action, noMod, "c", "Calendar", { { cons.act.func, focus.calendar } } })
a(i, { cons.cat.action, noMod, "d", "TablePlus", { { cons.act.launcher, "TablePlus" } } })
a(i, { cons.cat.action, noMod, "e", "email", { { cons.act.func, focus.email } } })
a(i, { cons.cat.submenu, noMod, "f", menuNameFloatHealth, { { cons.act.menu, menuNameFloatHealth } } })
a(i, { cons.cat.action, noMod, "g", "Google Meet & Notes", { { cons.act.func, placement.googleMeet } } })
a(i, { cons.cat.submenu, noMod, "h", menuNameHammerspoon, { { cons.act.menu, menuNameHammerspoon } } })
a(i, { cons.cat.action, noMod, "i", "IDE  (VS Code)", { { cons.act.launcher, "Visual Studio Code" } } })
a(i, { cons.cat.submenu, noMod, "j", menuNameJournal, { { cons.act.menu, menuNameJournal } } })
a(i, { cons.cat.submenu, noMod, "k", menuNameLearnLua, { { cons.act.menu, menuNameLearnLua } } })
a(i, { cons.cat.action, noMod, "l", menuNameLayout, { { cons.act.menu, menuNameLayout } } })
a(i, { cons.cat.action, noMod, "n", "Snippets", { { cons.act.func, snippets.chooseByUIAndType } } })
a(i, { cons.cat.action, noMod, "o", "Obsidian", { { cons.act.launcher, "Obsidian" } } })
a(i, { cons.cat.action, noMod, "p", "1Password", { { cons.act.launcher, "1Password" } } })
a(i, { cons.cat.action, noMod, "q", "Terminal Quick", { { cons.act.func, focus.terminalQuick } } })
a(i, { cons.cat.action, noMod, "r", "Right (App Nav)", { { cons.act.func, appNav.right } } })
a(i, { cons.cat.action, noMod, "s", "Slack", { { cons.act.func, focus.slack } } })
a(i, { cons.cat.action, noMod, "t", "terminal", { { cons.act.func, focus.terminal } } })
a(i, { cons.cat.submenu, noMod, "u", menuNameMusic, { { cons.act.menu, menuNameMusic } } })
a(i, { cons.cat.submenu, noMod, "v", menuNameVolume, { { cons.act.menu, menuNameVolume } } })
a(i, { cons.cat.action, noMod, "w", "Windows", { { cons.act.func, focus.showWindowChooser } } })
a(i, { cons.cat.submenu, noMod, "z", menuNamePersonal, { { cons.act.menu, menuNamePersonal } } })
a(i, { cons.cat.submenu, "shift", "/", menuNameHelp, { { cons.act.menu, menuNameHelp } } })
a(i, { cons.cat.action, noMod, ".", "Previous", { { cons.act.func, focus.previousApp } } })
a(i, { cons.cat.action, noMod, ",", "Window A", { { cons.act.func, focus.windowA } } })
a(i, { cons.cat.action, noMod, "x", "Window A Clear", { { cons.act.func, focus.windowAClear } } })
a(i, { cons.cat.action, noMod, "space", "Spotlight", { { cons.act.keycombo, { "cmd", "shift" }, "space" } } })
local menuMain = { menuItems = i, parentMenu = nil, menuHotkey = { noMod, "F10" } }

menuHammerMenuList = {
	[menuNameMain] = menuMain,
	[menuNameLearnLua] = menuLearnLua,
	[menuNameJournal] = menuJournal,
	[menuNamePersonal] = menuPersonal,
	[menuNameLayout] = menuLayout,
	[menuNameVolume] = menuVolume,
	[menuNameHammerspoon] = menuHammerspoon,
	[menuNameHelp] = menuHelp,
	[menuNameFloatHealth] = menuFloatHealth,
	[menuNameMusic] = menuMusic,
}
