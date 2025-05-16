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

local noMod = ""

--
-- 		{
-- 			cons.cat.action,
-- 			"",
-- 			"c",
-- 			"Check In",
-- 			{
-- 				{ cons.act.func, journal.appendPromptCheckIn },
-- 			},
-- 		},
-- 		{ cons.cat.action, noMod, "t", "Task", {
-- 			{ cons.act.func, journal.appendPromptTask },
-- 		} },
-- 		{ cons.cat.action, noMod, "v", "vim", {
-- 			{ cons.act.func, journal.appendVim },
-- 		} },
-- 	},
-- },
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

-- Menus
local mainMenu = "mainMenu"

-- Menu: Journal
local menuNameJournal = "Journal"
local i = {}
a(i, { cons.cat.action, noMod, "j", "Journal", { { cons.act.func, journal.appendPrompt } } })
a(i, { cons.cat.action, noMod, "c", "Check In", { { cons.act.func, journal.appendPromptCheckIn } } })
a(i, { cons.cat.action, noMod, "t", "Task", { { cons.act.func, journal.appendPromptTask } } })
a(i, { cons.cat.action, noMod, "v", "vim", { { cons.act.func, journal.appendVim } } })
local menuJournal = { menuItems = i, parentMenu = mainMenu }

-- Menu: Learn Lua
local menuNameLearnLua = "Learn Lua"
local i = {}
a(i, { cons.cat.action, noMod, "a", "Aggregate", { { cons.act.func, journal.appendPrompt } } })
a(i, { cons.cat.action, noMod, "b", "Burn", { { cons.act.func, journal.appendPrompt } } })
local menuLearnLua = { menuItems = i, parentMenu = mainMenu }

-- Menu: Personal
local menuNamePersonal = "Personal"
local i = {}
a(i, { cons.cat.action, noMod, "B", "Bambu Studio", { { cons.act.launcher, "BambuStudio" } } })
a(i, { cons.cat.action, noMod, "F", "Fusion", { { cons.act.launcher, "Fusion" } } })
a(i, { cons.cat.action, noMod, "P", "PrusaSlicer", { { cons.act.launcher, "PrusaSlicer" } } })
local menuPersonal = { menuItems = i, parentMenu = mainMenu }

local menuNameLayout = "Layout (Placement)"
local i = {}
a(i, { cons.cat.action, noMod, "l", "Left", { { cons.act.func, placement.left } } })
a(i, { cons.cat.action, noMod, "r", "Right", { { cons.act.func, placement.right } } })
a(i, { cons.cat.action, noMod, "m", "Max", { { cons.act.func, placement.maximize } } })
local menuLayout = { menuItems = i, parentMenu = mainMenu }

-- Applications Menus
local personalMenu = "personalMenu"
local utilitiesMenu = "utilitiesMenu"
local journalMenu = "journalMenu"
local floatHealthMenu = "floatHealthMenu"

-- Hammerspoon menu
local hammerspoonMenu = "hammerspoonMenu"

local helpMenu = "helpMenu"
local layoutMenu = "layoutMenu"
local scriptsMenu = "scriptsMenu"
local textMenu = "textMenu"
local toggleMenu = "toggleMenu"
-- Window menu
local resizeMenu = "resizeMenu"
local volumeMenu = "volumeMenu"
local musicMenu = "musicMenu"

menuHammerMenuList = {

	-- Item Definitions. Keep the syntax noise here and let the structure be easier to maintain below.
	------------------------------------------------------------------------------------------------
	-- Main Menu
	------------------------------------------------------------------------------------------------
	[mainMenu] = {
		parentMenu = nil,
		menuHotkey = { noMod, "F10" },
		menuItems = {
			{ cons.cat.action, noMod, "a", "API (Postman)", { { cons.act.launcher, "Postman" } } },
			{ cons.cat.action, noMod, "b", "Browser", { { cons.act.func, focus.browser } } },
			{ cons.cat.action, noMod, "c", "Calendar", { { cons.act.func, focus.calendar } } },
			{ cons.cat.action, noMod, "d", "TablePlus", { { cons.act.launcher, "TablePlus" } } },
			{ cons.cat.action, noMod, "e", "email", { { cons.act.func, focus.email } } },
			{ cons.cat.action, noMod, "f", "Float Health", { { cons.act.menu, floatHealthMenu } } },
			{ cons.cat.action, noMod, "g", "Google Meet & Notes", { { cons.act.func, placement.googleMeet } } },
			{ cons.cat.submenu, noMod, "h", "Hammerspoon", { { cons.act.menu, hammerspoonMenu } } },
			{ cons.cat.action, noMod, "i", "IDE  (VS Code)", { { cons.act.launcher, "Visual Studio Code" } } },
			{ cons.cat.submenu, noMod, "j", menuNameJournal, { { cons.act.menu, menuNameJournal } } },
			{ cons.cat.submenu, noMod, "k", menuNameLearnLua, { { cons.act.menu, menuNameLearnLua } } },
			{ cons.cat.action, noMod, "l", menuNameLayout, { { cons.act.menu, menuNameLayout } } },
			{ cons.cat.action, noMod, "m", "Music", { { cons.act.func, focus.music } } },
			{ cons.cat.action, noMod, "n", "Snippets", { { cons.act.func, snippets.chooseByUIAndType } } },
			{ cons.cat.action, noMod, "o", "Obsidian", { { cons.act.launcher, "Obsidian" } } },
			{ cons.cat.action, noMod, "p", "1Password", { { cons.act.launcher, "1Password" } } },
			{ cons.cat.action, noMod, "q", "Terminal Quick", { { cons.act.func, focus.terminalQuick } } },
			{ cons.cat.action, noMod, "r", "Right (App Nav)", { { cons.act.func, appNav.right } } },
			{ cons.cat.action, noMod, "s", "Slack", { { cons.act.func, focus.slack } } },
			{ cons.cat.action, noMod, "t", "terminal", { { cons.act.func, focus.terminal } } },
			{ cons.cat.action, noMod, "u", "mUsic", { { cons.act.menu, musicMenu } } },
			{ cons.cat.submenu, noMod, "v", "Volume", { { cons.act.menu, volumeMenu } } },
			{ cons.cat.action, noMod, "w", "Windows", { { cons.act.func, focus.showWindowChooser } } },
			-- { cons.cat.action, noMod, "y", "Cycle Windows", { { cons.act.func, focus.cycleWindows } } },
			-- {cons.cat.action, '', 'z', 'Zoom', { {cons.act.launcher, 'zoom.us'} }},
			-- { cons.cat.action, noMod, "z", "zed", { { cons.act.launcher, "Zed" } } },
			{ cons.cat.submenu, noMod, "z", menuNamePersonal, { { cons.act.menu, menuNamePersonal } } },
			{ cons.cat.submenu, "shift", "/", "Help", { { cons.act.menu, helpMenu } } },
			{ cons.cat.action, noMod, ".", "Previous", { { cons.act.func, focus.previousApp } } },
			{ cons.cat.action, noMod, ",", "Window A", { { cons.act.func, focus.windowA } } },
			{ cons.cat.action, noMod, "x", "Window A Clear", { { cons.act.func, focus.windowAClear } } },
			{ cons.cat.submenu, noMod, "/", "Scripts", { { cons.act.menu, scriptsMenu } } },
			{ cons.cat.action, noMod, "space", "Spotlight", { { cons.act.keycombo, { "cmd", "shift" }, "space" } } },
		},
	},

	[menuNameLearnLua] = menuLearnLua,
	[menuNameJournal] = menuJournal,
	[menuNamePersonal] = menuPersonal,
	[menuNameLayout] = menuLayout,

	------------------------------------------------------------------------------------------------
	-- Help Menu
	------------------------------------------------------------------------------------------------
	helpMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"",
				"H",
				"Hammerspoon Manual",
				{
					{
						cons.act.func,
						function()
							hs.doc.hsdocs.forceExternalBrowser(true)
							hs.doc.hsdocs.moduleEntitiesInSidebar(true)
							hs.doc.hsdocs.help()
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"M",
				"MenuHammer Documentation",
				{
					{ cons.act.openurl, "https://github.com/FryJay/MenuHammer" },
				},
			},
		},
	},

	floatHealthMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{ cons.cat.action, noMod, "P", "Postman", { { cons.act.launcher, "Postman" } } },
			{ cons.cat.action, noMod, "Y", "Playwright (Chromium)", { { cons.act.launcher, "Chromium" } } },
			{ cons.cat.action, noMod, "z", "zed", { { cons.act.launcher, "Zed" } } },
		},
	},
	musicMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{ cons.cat.action, noMod, "space", "Toggle", { { cons.act.func, mpd.toggle } } },
			{ cons.cat.action, noMod, "t", "Toggle", { { cons.act.func, mpd.toggle } } },
			{ cons.cat.action, noMod, "p", "Play", { { cons.act.func, mpd.play } } },
			{ cons.cat.action, noMod, "u", "Pause", { { cons.act.func, mpd.pause } } },
		},
	},
	------------------------------------------------------------------------------------------------
	-- Hammerspoon Menu
	------------------------------------------------------------------------------------------------
	hammerspoonMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"",
				"C",
				"Hammerspoon Console",
				{
					{
						cons.act.func,
						function()
							hs.toggleConsole()
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"H",
				"Hammerspoon Manual",
				{
					{
						cons.act.func,
						function()
							hs.doc.hsdocs.forceExternalBrowser(true)
							hs.doc.hsdocs.moduleEntitiesInSidebar(true)
							hs.doc.hsdocs.help()
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"R",
				"Reload Hammerspoon",
				{
					{
						cons.act.func,
						function()
							hs.reload()
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"Q",
				"Quit Hammerspoon",
				{
					{
						cons.act.func,
						function()
							os.exit()
						end,
					},
				},
			},
		},
	},

	------------------------------------------------------------------------------------------------
	-- Media Menu
	------------------------------------------------------------------------------------------------
	mediaMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{ cons.cat.action, noMod, "A", "iTunes", {
				{ cons.act.launcher, "iTunes" },
			} },
			{ cons.cat.action, noMod, "H", "Previous Track", {
				{ cons.act.mediakey, "previous" },
			} },
			{ cons.cat.action, noMod, "J", "Volume Down", {
				{ cons.act.mediakey, "volume", -10 },
			} },
			{ cons.cat.action, noMod, "K", "Volume Up", {
				{ cons.act.mediakey, "volume", 10 },
			} },
			{ cons.cat.action, noMod, "L", "Next Track", {
				{ cons.act.mediakey, "next" },
			} },
			{ cons.cat.action, noMod, "X", "Mute/Unmute", {
				{ cons.act.mediakey, "mute" },
			} },
			{ cons.cat.action, noMod, "S", "Play/Pause", {
				{ cons.act.mediakey, "playpause" },
			} },
			{
				cons.cat.action,
				"",
				"I",
				"Brightness Down",
				{
					{ cons.act.mediakey, "brightness", -10 },
				},
			},
			{
				cons.cat.action,
				"",
				"O",
				"Brightness Up",
				{
					{ cons.act.mediakey, "brightness", 10 },
				},
			},
		},
	},

	volumeMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"",
				"1",
				"10%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(10)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"2",
				"20%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(20)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"3",
				"30%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(30)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"t",
				"30%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(30)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"4",
				"50%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(40)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"5",
				"50%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(50)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"f",
				"50%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(50)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"6",
				"60%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(60)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"7",
				"70%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(70)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"s",
				"70%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(70)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"8",
				"80%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(80)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"e",
				"80%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(80)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"9",
				"90%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(90)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"n",
				"90%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(90)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"h",
				"100%",
				{
					{
						cons.act.func,
						function()
							sound.setVolume(100)
						end,
					},
				},
			},
		},
	},

	------------------------------------------------------------------------------------------------
	-- Scripts Menu
	------------------------------------------------------------------------------------------------
	[scriptsMenu] = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {},
	},

	------------------------------------------------------------------------------------------------
	-- System Menu
	------------------------------------------------------------------------------------------------
	systemMenu = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"shift",
				"F",
				"Force Quit Frontmost App",
				{
					{ cons.act.system, cons.sys.forcequit },
				},
			},
			{
				cons.cat.action,
				"",
				"L",
				"Lock Screen",
				{
					{ cons.act.system, cons.sys.lockscreen },
				},
			},
			{
				cons.cat.action,
				"shift",
				"R",
				"Restart System",
				{
					{ cons.act.system, cons.sys.restart, true },
				},
			},
			{
				cons.cat.action,
				"",
				"S",
				"Start Screensaver",
				{
					{ cons.act.system, cons.sys.screensaver },
				},
			},
			{
				cons.cat.action,
				"shift",
				"S",
				"Shutdown System",
				{
					{ cons.act.system, cons.sys.shutdown, true },
				},
			},
			{ cons.cat.action, noMod, "Q", "Logout", {
				{ cons.act.system, cons.sys.logout },
			} },
			{
				cons.cat.action,
				"shift",
				"Q",
				"Logout Immediately",
				{
					{ cons.act.system, cons.sys.logoutnow },
				},
			},
			{
				cons.cat.action,
				"",
				"U",
				"Switch User",
				{
					{ cons.act.system, cons.sys.switchuser, true },
				},
			},
			{
				cons.cat.action,
				"",
				"V",
				"Activity Monitor",
				{
					{ cons.act.launcher, "Activity Monitor" },
				},
			},
			{
				cons.cat.action,
				"",
				"X",
				"System Preferences",
				{
					{ cons.act.launcher, "System Preferences" },
				},
			},
		},
	},

	------------------------------------------------------------------------------------------------
	-- Text Menu
	------------------------------------------------------------------------------------------------
	[textMenu] = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"",
				"C",
				"Remove clipboard format",
				{
					{
						cons.act.func,
						function()
							local pasteboardContents = hs.pasteboard.getContents()
							hs.pasteboard.setContents(pasteboardContents)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"E",
				"Empty the clipboard",
				{
					{
						cons.act.func,
						function()
							hs.pasteboard.setContents("")
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"T",
				"Type clipboard contents",
				{
					{ cons.act.typetext, "@@mhClipboardText@@" },
				},
			},
		},
	},

	------------------------------------------------------------------------------------------------
	-- Toggle menu
	------------------------------------------------------------------------------------------------
	[toggleMenu] = {
		parentMenu = mainMenu,
		menuHotkey = nil,
		menuItems = {
			{
				cons.cat.action,
				"",
				"C",
				"Caffeine",
				{
					{
						cons.act.func,
						function()
							toggleCaffeine()
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"D",
				"Hide/Show Dock",
				{
					{ cons.act.keycombo, { "cmd", "alt" }, "d" },
				},
			},
			{
				cons.cat.action,
				"",
				"S",
				"Start Screensaver",
				{
					{ cons.act.system, cons.sys.screensaver },
				},
			},
			{
				cons.cat.action,
				"shift",
				"W",
				"Disable wi-fi",
				{
					{
						cons.act.func,
						function()
							hs.wifi.setPower(false)
						end,
					},
				},
			},
			{
				cons.cat.action,
				"",
				"W",
				"Enable wi-fi",
				{
					{
						cons.act.func,
						function()
							hs.wifi.setPower(true)
						end,
					},
				},
			},
		},
	},
}
