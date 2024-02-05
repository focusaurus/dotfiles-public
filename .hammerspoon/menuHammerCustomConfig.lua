local appNav = require('app-nav')
local focus = require('focus')
local fuzzball = require('fuzzball')
local journal = require('journal')
local placement = require('placement')
local snippets = require('snippets')
local sound = require('sound')
local dev = require('dev')

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

-- Editor path
menuTextEditor = '/usr/local/bin/emacsclient -c'

-- Location of the askpass executable.  Required for running script with admin privs.
askpassLocation = '/usr/local/bin/ssh-askpass'

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
--menuItemFont = 'JetBrains Mono'
menuItemFontSize = 16
menuItemTextAlign = 'left'

---------------------------------------- Color options ---------------------------------------------
menuItemColors = {
    -- The default colors to use.
    default = {
        background = '#000000',
        text = '#aaaaaa'
    },
    -- The colors to use for the Exit menu item
    exit = {
        background = '#000000',
        text = '#C1666B'
    },
    -- The colors to use for the Back menu items
    back = {
        background = '#000000',
        text = '#E76F51'
    },
    -- The colors to use for menu menu items
    submenu = {
    },
    -- The colors to use for navigation menu items
    navigation = {
        background = '#000000',
        text = '#4281A4'
    },
    -- The colors to use for empty menu items
    empty = {
        background = '#000000',
        text = '#aaaaaa'
    },
    -- The colors to use for action menu items
    action = {
        background = '#000000',
        text = '#7A3B69'
    },
    menuBarActive = {
        background = '#ff0000',
        text = '#000000'
    },
    menuBarIdle = {
        background = '#00ff00',
        text = '#000000'
    },
    display = {
        background = '#000000',
        text = '#48A9A6'
    }
}

----------------------------------------------------------------------------------------------------
-------------------------------------- Menu bar options --------------------------------------------
----------------------------------------------------------------------------------------------------

-- Key bindings

-- The hotkey that will enable/disable MenuHammer
menuHammerToggleKey = {{'cmd', 'shift', 'ctrl'}, 'Q'}

-- Menu Prefixes
menuItemPrefix = {
    action = '↩',
    submenu = '→',
    back = '←',
    exit = 'x',
    navigation = '↩',
    -- navigation = '⎋',
    empty = '',
    display = '',
}

-- Menu item separator
menuKeyItemSeparator = ': '

----------------------------------------------------------------------------------------------------
--------------------------------------- Default Menus ----------------------------------------------
----------------------------------------------------------------------------------------------------

-- Menus
local mainMenu = 'mainMenu'

-- Applications Menus
local applicationMenu = 'applicationMenu'
local utilitiesMenu = 'utilitiesMenu'
local journalMenu = 'journalMenu'

-- Hammerspoon menu
local hammerspoonMenu = 'hammerspoonMenu'

-- Help menu
local helpMenu = 'helpMenu'

-- Layout menu
local layoutMenu = 'layoutMenu'

-- Media menu
local mediaMenu = 'mediaMenu'


-- Scripts menu
local scriptsMenu = 'scriptsMenu'

-- System menus
local systemMenu = 'systemMenu'

-- Text menu
local textMenu = 'textMenu'

-- Toggles menu
local toggleMenu = 'toggleMenu'

-- Window menu
local resizeMenu = 'resizeMenu'
local volumeMenu = 'volumeMenu'

menuHammerMenuList = {

    ------------------------------------------------------------------------------------------------
    -- Main Menu
    ------------------------------------------------------------------------------------------------
    [mainMenu] = {
        parentMenu = nil,
        menuHotkey = {{}, 'F10'},
        menuItems = {
            {cons.cat.submenu, 'shift', '/', 'Help', { {cons.act.menu, helpMenu} }},
            {cons.cat.submenu, '', 'a', 'Applications', { {cons.act.menu, applicationMenu} }},
            {cons.cat.action, '', 'b', 'Browser', { {cons.act.func, focus.browser} }},
            {cons.cat.action, '', 'e', 'email', { {cons.act.func, focus.email} }},
            {cons.cat.submenu, '', 'j', 'Journal', { {cons.act.menu, journalMenu} }},
            {cons.cat.action, '', 'c', 'Calendar', { {cons.act.func, focus.calendar} }},
            {cons.cat.action, '', 'd', 'Sequel Ace', { {cons.act.launcher, 'Sequel Ace'} }},
            {cons.cat.action, '', 'o', 'Obsidian', { {cons.act.launcher, 'Obsidian'} }},
            {cons.cat.submenu, '', 'h', 'Hammerspoon', { {cons.act.menu, hammerspoonMenu} }},
            -- {cons.cat.submenu, '', 'm', 'Media Controls', { {cons.act.menu, mediaMenu} }},
            -- {cons.cat.submenu, '', 'g', 'Toggles', { {cons.act.menu, toggleMenu} }},
            {cons.cat.submenu, '', '/', 'Scripts', { {cons.act.menu, scriptsMenu} }},
            {cons.cat.action, '', 'space', 'Spotlight', { {cons.act.keycombo, {'cmd', 'shift'}, 'space'} }},
            -- {cons.cat.action, '', 'x', 'Firefox', { {cons.act.launcher, 'Firefox'} }},
            {cons.cat.action, '', 'y', 'Cycle Windows', { {cons.act.func, focus.cycleWindows} }},
            {cons.cat.action, '', 'f', 'Fuzzball', { {cons.act.func, fuzzball.chooseScript } }},
            {cons.cat.action, '', 'l', 'Left (App Nav)', { {cons.act.func, appNav.left } }},
            {cons.cat.action, '', 'r', 'Right (App Nav)', { {cons.act.func, appNav.right } }},
            {cons.cat.action, '', 'm', 'Music', { {cons.act.func, focus.music } }},
            {cons.cat.action, '', 'n', 'Snippet', { {cons.act.func, snippets.chooseByUIAndType } }},
            {cons.cat.action, '', 'p', '1Password', { {cons.act.launcher, '1Password'} }},
            {cons.cat.action, '', 't', 'terminal', { {cons.act.func, focus.terminal} }},
            {cons.cat.action, '', 'g', 'Google Meet & Notes', { {cons.act.func, placement.googleMeet} }},
            {cons.cat.action, '', 'z', 'Zoom', { {cons.act.launcher, 'zoom.us'} }},
            {cons.cat.action, '', 'q', 'Terminal Quick', { {cons.act.func, focus.terminalQuick} }},
            {cons.cat.action, '', 'i', 'IDE  (VS Code)', { {cons.act.launcher, 'Visual Studio Code'} }},
            {cons.cat.submenu, '', 'v', 'Volume', { {cons.act.menu, volumeMenu} }},
            {cons.cat.action, '', 'w', 'Windows', { {cons.act.func, focus.showWindowChooser} }},
            {cons.cat.action, '', 's', 'Slack', { {cons.act.func, focus.slack} }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Help Menu
    ------------------------------------------------------------------------------------------------
    helpMenu = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'H', 'Hammerspoon Manual', {
                {cons.act.func, function()
                      hs.doc.hsdocs.forceExternalBrowser(true)
                      hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                      hs.doc.hsdocs.help()
                end }
            }},
            {cons.cat.action, '', 'M', 'MenuHammer Documentation', {
                {cons.act.openurl, 'https://github.com/FryJay/MenuHammer'},
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Application Menu
    ------------------------------------------------------------------------------------------------
    applicationMenu = {
        parentMenu = mainMenu,
        menuHotkey = {{'cmd', 'alt', 'ctrl'}, 'a'},
        menuItems = {
            {cons.cat.action, '', '1', '1Password', { {cons.act.launcher, '1Password 7'} }},
            {cons.cat.action, '', 'A', 'App Store', { {cons.act.launcher, 'App Store'} }},
            {cons.cat.action, '', 'C', 'Calculator', { {cons.act.launcher, 'Calculator'} }},
            {cons.cat.action, '', 'D', 'Dash', { {cons.act.launcher, 'Dash'} }},
            {cons.cat.action, '', 'F', 'Finder', { {cons.act.launcher, 'Finder'} }},
            {cons.cat.action, '', 'K', 'Karabiner', { {cons.act.launcher, 'Karabiner-Elements'} }},
            {cons.cat.action, '', 'I', 'Insomnia', { {cons.act.launcher, 'Insomnia'} }},
            {cons.cat.action, '', 'P', 'Postman', { {cons.act.launcher, 'Postman'} }},
            {cons.cat.submenu, '', 'U', 'Utilities', { {cons.act.menu, utilitiesMenu} }},
            {cons.cat.action, '', 'W', 'Warp', { {cons.act.launcher, 'Warp'} }},
        }
    },
    --------------------------------------------------------------------
    -- Journal Menu
    ------------------------------------------------------------------------------------------------
    journalMenu = {
        parentMenu = mainMenu,
        meunHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'j', 'Journal', {
                {cons.act.func, journal.appendPrompt}
            }},
            {cons.cat.action, '', 's', 'Standup', {
                {cons.act.func, journal.appendPromptStandup}
            }},
            {cons.cat.action, '', 't', 'Task', {
                {cons.act.func, journal.appendPromptTask}
            }},
            {cons.cat.action, '', 'v', 'vim', {
                {cons.act.func, journal.appendVim}
            }},
        }
    },


    ------------------------------------------------------------------------------------------------
    -- Utilities Menu
    ------------------------------------------------------------------------------------------------
    utilitiesMenu = {
        parentMenu = applicationMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'A', 'Activity Monitor', {
                {cons.act.launcher, 'Activity Monitor'}
            }},
            {cons.cat.action, '', 'C', 'Console', {
                {cons.act.launcher, 'Console'}
            }},
            {cons.cat.action, '', 'S', 'System Information', {
                {cons.act.launcher, 'System Information'}
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Hammerspoon Menu
    ------------------------------------------------------------------------------------------------
    hammerspoonMenu = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'C', 'Hammerspoon Console', {
                {cons.act.func, function() hs.toggleConsole() end }
            }},
            {cons.cat.action, '', 'H', 'Hammerspoon Manual', {
                {cons.act.func, function()
                      hs.doc.hsdocs.forceExternalBrowser(true)
                      hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                      hs.doc.hsdocs.help()
                end }
            }},
            {cons.cat.action, '', 'R', 'Reload Hammerspoon', {
                {cons.act.func, function() hs.reload() end }
            }},
            {cons.cat.action, '', 'Q', 'Quit Hammerspoon', {
                {cons.act.func, function() os.exit() end }
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Layout Menu
    ------------------------------------------------------------------------------------------------
    [layoutMenu] = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'E', 'Split Safari/iTunes', {
                 {cons.act.func, function()
                      -- See Hammerspoon layout documentation for more info on this
                      local mainScreen = hs.screen{x=0,y=0}
                      hs.layout.apply({
                              {'Safari', nil, mainScreen, hs.layout.left50, nil, nil},
                              {'iTunes', nil, mainScreen, hs.layout.right50, nil, nil},
                      })
                 end }
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Media Menu
    ------------------------------------------------------------------------------------------------
    mediaMenu = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'A', 'iTunes', {
                {cons.act.launcher, 'iTunes'}
            }},
            {cons.cat.action, '', 'H', 'Previous Track', {
                {cons.act.mediakey, 'previous'}
            }},
            {cons.cat.action, '', 'J', 'Volume Down', {
                {cons.act.mediakey, 'volume', -10}
            }},
            {cons.cat.action, '', 'K', 'Volume Up', {
                {cons.act.mediakey, 'volume', 10}
            }},
            {cons.cat.action, '', 'L', 'Next Track', {
                {cons.act.mediakey, 'next'}
            }},
            {cons.cat.action, '', 'X', 'Mute/Unmute', {
                {cons.act.mediakey, 'mute'}
            }},
            {cons.cat.action, '', 'S', 'Play/Pause', {
                {cons.act.mediakey, 'playpause'}
            }},
            {cons.cat.action, '', 'I', 'Brightness Down', {
                {cons.act.mediakey, 'brightness', -10}
            }},
            {cons.cat.action, '', 'O', 'Brightness Up', {
                {cons.act.mediakey, 'brightness', 10}
            }},
        }
    },

    volumeMenu = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', '1', '10%', {
                {cons.act.func, function() sound.setVolume(10) end}
            }},
            {cons.cat.action, '', '2', '20%', {
                {cons.act.func, function() sound.setVolume(20) end}
            }},
            {cons.cat.action, '', '3', '30%', {
                {cons.act.func, function() sound.setVolume(30) end}
            }},
            {cons.cat.action, '', 't', '30%', {
                {cons.act.func, function() sound.setVolume(30) end}
            }},
            {cons.cat.action, '', '4', '50%', {
                {cons.act.func, function() sound.setVolume(40) end}
            }},
            {cons.cat.action, '', '5', '50%', {
                {cons.act.func, function() sound.setVolume(50) end}
            }},
            {cons.cat.action, '', 'f', '50%', {
                {cons.act.func, function() sound.setVolume(50) end}
            }},
            {cons.cat.action, '', '6', '60%', {
                {cons.act.func, function() sound.setVolume(60) end}
            }},
            {cons.cat.action, '', '7', '70%', {
                {cons.act.func, function() sound.setVolume(70) end}
            }},
            {cons.cat.action, '', 's', '70%', {
                {cons.act.func, function() sound.setVolume(70) end}
            }},
            {cons.cat.action, '', '8', '80%', {
                {cons.act.func, function() sound.setVolume(80) end}
            }},
            {cons.cat.action, '', 'e', '80%', {
                {cons.act.func, function() sound.setVolume(80) end}
            }},
            {cons.cat.action, '', '9', '90%', {
                {cons.act.func, function() sound.setVolume(90) end}
            }},
            {cons.cat.action, '', 'n', '90%', {
                {cons.act.func, function() sound.setVolume(90) end}
            }},
            {cons.cat.action, '', 'h', '100%', {
                {cons.act.func, function() sound.setVolume(100) end}
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Scripts Menu
    ------------------------------------------------------------------------------------------------
    [scriptsMenu] = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
        }
    },

    ------------------------------------------------------------------------------------------------
    -- System Menu
    ------------------------------------------------------------------------------------------------
    systemMenu = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, 'shift', 'F', 'Force Quit Frontmost App', {
                {cons.act.system, cons.sys.forcequit},
            }},
            {cons.cat.action, '', 'L', 'Lock Screen', {
                {cons.act.system, cons.sys.lockscreen},
            }},
            {cons.cat.action, 'shift', 'R', 'Restart System', {
                {cons.act.system, cons.sys.restart, true},
            }},
            {cons.cat.action, '', 'S', 'Start Screensaver', {
                {cons.act.system, cons.sys.screensaver},
            }},
            {cons.cat.action, 'shift', 'S', 'Shutdown System', {
                {cons.act.system, cons.sys.shutdown, true},
            }},
            {cons.cat.action, '', 'Q', 'Logout', {
                {cons.act.system, cons.sys.logout}
            }},
            {cons.cat.action, 'shift', 'Q', 'Logout Immediately', {
                {cons.act.system, cons.sys.logoutnow},
            }},
            {cons.cat.action, '', 'U', 'Switch User', {
                {cons.act.system, cons.sys.switchuser, true},
            }},
            {cons.cat.action, '', 'V', 'Activity Monitor', {
                {cons.act.launcher, 'Activity Monitor'},
            }},
            {cons.cat.action, '', 'X', 'System Preferences', {
                {cons.act.launcher, 'System Preferences'},
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Text Menu
    ------------------------------------------------------------------------------------------------
    [textMenu] = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'C', 'Remove clipboard format', {
                 {cons.act.func, function()
                      local pasteboardContents = hs.pasteboard.getContents()
                      hs.pasteboard.setContents(pasteboardContents)
                 end },
            }},
            {cons.cat.action, '', 'E', 'Empty the clipboard', {
                 {cons.act.func, function() hs.pasteboard.setContents('') end}
            }},
            {cons.cat.action, '', 'T', 'Type clipboard contents', {
                 {cons.act.typetext, '@@mhClipboardText@@'}
            }},
        }
    },

    ------------------------------------------------------------------------------------------------
    -- Toggle menu
    ------------------------------------------------------------------------------------------------
    [toggleMenu] = {
        parentMenu = mainMenu,
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'C', 'Caffeine', {
                 {cons.act.func, function() toggleCaffeine() end }
            }},
            {cons.cat.action, '', 'D', 'Hide/Show Dock', {
                 {cons.act.keycombo, {'cmd', 'alt'}, 'd'}
            }},
            {cons.cat.action, '', 'S', 'Start Screensaver', {
                 {cons.act.system, cons.sys.screensaver},
            }},
            {cons.cat.action, 'shift', 'W', 'Disable wi-fi', {
                 {cons.act.func, function() hs.wifi.setPower(false) end }
            }},
            {cons.cat.action, '', 'W', 'Enable wi-fi', {
                 {cons.act.func, function() hs.wifi.setPower(true) end }
            }},
        }
    },
}
