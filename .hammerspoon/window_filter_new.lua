--- === hs.window.filter ===
---
--- Filter windows by application, title, location on screen and more,
--- and easily subscribe to events on these windows
---
--- This is a complete rewrite of the original hs.window.filter module,
--- maintaining full API compatibility while improving performance,
--- reliability, and maintainability.
---
--- ## Development Notes
---
--- **Style**: Follows `window.lua` conventions (local caching, minimal whitespace)
---
--- **Testing**: Load via hs CLI for manual testing:
--- ```
--- /Users/dmg/bin/osx/hs -c 'local wf = dofile("/Users/dmg/git.forks/hammerspoon/extensions/window/window_filter_new.lua"); print(wf._VERSION)'
--- ```
---
--- **Test utilities**:
--- ```
--- /Users/dmg/bin/osx/hs -c '
--- local wf = dofile("/Users/dmg/git.forks/hammerspoon/extensions/window/window_filter_new.lua")
--- -- Test safeCall with valid call
--- local win = hs.window.focusedWindow()
--- if win then
---   print("safeCall title:", wf._safeCall(win.title, win))
---   print("safeGetScreenId:", wf._safeGetScreenId(win))
--- end
--- -- Test safeCall with nil
--- print("safeCall nil fn:", wf._safeCall(nil, {}))
--- -- Test safeCall with error
--- print("safeCall error:", wf._safeCall(function() error("test") end, nil))
--- '
--- ```
---
--- @module hs.window.filter

----------------------------------------------------------------------
-- SECTION 1: LOCAL CACHING AND IMPORTS
----------------------------------------------------------------------
-- Following window.lua style: cache globals for performance
-- Use hs.* globals directly (no require) for dofile() compatibility

local pairs, ipairs, type, setmetatable = pairs, ipairs, type, setmetatable
local pcall, error, tostring, tonumber = pcall, error, tostring, tonumber
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local sformat, smatch, sfind = string.format, string.match, string.find
local floor, min, max = math.floor, math.min, math.max

-- hs.* caching for dofile() compatibility
local timer = hs.timer
local logger = hs.logger
local log = logger.new('wfilter')

----------------------------------------------------------------------
-- SECTION 2: MODULE TABLE
----------------------------------------------------------------------

local windowfilter = {}
windowfilter._VERSION = '2.0.0-dev'

----------------------------------------------------------------------
-- SECTION 3: CONFIGURATION
----------------------------------------------------------------------

--- hs.window.filter._config
--- Variable
--- Internal configuration table for tuning window filter behavior.
---
--- This table centralizes all configuration parameters for the window filter system.
--- While internal (prefixed with `_`), it is exposed to allow advanced users to tune
--- performance and filtering behavior. Changes take effect immediately for new operations.
---
--- The configuration is organized into the following sections:
---
--- **timing** - Controls delays and retry behavior (all values in seconds):
---  * `retryDelay` (number, default 0.2): Base delay between retry attempts when registering
---    windows or apps. The actual delay increases with each retry (retryCount * retryDelay).
---    When a window or app is first detected, it may not be fully initialized. The system
---    retries registration until the window/app is ready or max retries is reached.
---  * `maxRetries` (number, default 5): Maximum number of attempts to register a window or app
---    before giving up. With default settings, the system will try for up to 3 seconds
---    (0.2 + 0.4 + 0.6 + 0.8 + 1.0) before abandoning registration.
---  * `movedDebounce` (number, default 0.5): Debounce interval for window moved events.
---    When a window is being dragged or resized, macOS fires many rapid move events.
---    This setting coalesces them into a single event fired after movement stops.
---  * `titleDebounce` (number, default 0.5): Debounce interval for window title changes.
---    Some apps update titles frequently (e.g., terminals showing command output).
---    This prevents excessive event firing during rapid title updates.
---  * `spaceChangeDelay` (number, default 0.5): Delay after a Mission Control Space change
---    before refreshing window state. macOS needs time to settle after space switches;
---    querying too early may return stale or incomplete window information.
---  * `zombieCleanupInterval` (number, default 300): Seconds between checks for "zombie" apps.
---    Zombie apps are tracked apps whose processes have terminated but weren't properly
---    cleaned up due to missed termination events. This periodic cleanup prevents memory
---    leaks from accumulated stale app references.
---
--- **performance** - Controls performance-related behavior:
---  * `accessibilityTimeout` (number, default 0.5): Maximum seconds to wait for macOS
---    Accessibility API responses. Some apps (especially Electron-based ones) can be slow
---    to respond to accessibility queries. This timeout prevents the system from hanging.
---  * `skipSlowApps` (boolean, default false): If true, apps that exceed the accessibility
---    timeout will be skipped entirely and not tracked. If false (default), slow apps are
---    still tracked but with degraded responsiveness. Enable this if you experience
---    performance issues with specific slow apps.
---
--- **filtering** - Default filtering rules applied during window matching:
---  * `allowedRoles` (table): Map of allowed window subroles. macOS assigns each window a
---    "subrole" via the Accessibility API that describes its type. Only windows with roles
---    in this table pass the default filter. Default allowed roles:
---    - `AXStandardWindow`: Normal application windows (documents, main windows)
---    - `AXDialog`: Modal and non-modal dialog boxes (alerts, preferences)
---    - `AXSystemDialog`: System-level dialogs (authentication prompts, system alerts)
---    Windows with other roles (e.g., `AXFloatingWindow` for tooltips, `AXSheet` for
---    attached dialogs) are filtered out unless explicitly allowed in filter rules.
---
--- **prefilter** - Early-stage filtering applied before windows are tracked:
---   PreFilter runs when windows are first detected, before creating watchers. This provides
---   a performance optimization by avoiding tracking overhead for windows that will never
---   be needed. Unlike filter rules (which can vary per windowfilter instance), PreFilter
---   settings apply globally to all instances.
---
---  * `ignoreBundleIDs` (table): Map of bundle IDs to ignore. Bundle IDs uniquely identify
---    macOS applications (e.g., "com.apple.Safari"). Apps with these bundle IDs are never
---    tracked, even by an "allow all" windowfilter. Default includes:
---    - `com.apple.WebKit.WebContent`: Safari/WebKit helper processes that render web content.
---      These appear as separate "apps" but are not user-facing windows.
---    Add entries with: `hs.window.filter._config.prefilter.ignoreBundleIDs['com.example.app'] = true`
---  * `ignoreAppPattern` (string, default "^QTKitServer%-"): Lua pattern matched against app
---    names. Apps whose names match this pattern are ignored. The default pattern filters
---    QTKitServer processes (legacy QuickTime helper processes). Use Lua pattern syntax:
---    `^` = start of string, `%-` = literal hyphen (escaped), `$` = end of string.
---  * `requireTitle` (boolean, default false): If true, windows must have a non-empty title
---    to be tracked. Useful for filtering out temporary or placeholder windows that apps
---    create before setting a proper title.
---  * `requireRole` (boolean, default false): If true, windows must have a non-empty subrole
---    to be tracked. Some system windows lack roles; enabling this filters them out.
---  * `minTitleLength` (number, default 0): Minimum title length for windows to be tracked.
---    Windows with titles shorter than this are ignored. Set to 1 to require any title,
---    or higher to filter out windows with very short titles.
---  * `allowedRoles` (table or nil, default nil): If set, only windows with subroles in this
---    table are tracked. Unlike `filtering.allowedRoles` (which affects matching), this
---    prevents windows from being tracked at all. When nil, no role-based prefiltering
---    occurs (all roles are tracked, then filtered during matching).
---
--- **skipApps** - Lists of app names to skip (builds `ignoreAlways` and `ignoreInDefaultFilter`):
---   These lists populate the public `hs.window.filter.ignoreAlways` and
---   `hs.window.filter.ignoreInDefaultFilter` tables at module load time.
---
---  * `noPid` (table): Apps that trigger "No accessibility access" console warnings.
---    These are typically helper processes or agents that macOS reports as apps but
---    cannot be queried via Accessibility APIs. Including them here suppresses warnings
---    and avoids futile tracking attempts.
---  * `noWindows` (table): Apps that technically exist but have no user-visible windows.
---    Examples include system agents, background services, and helper processes.
---    These are always ignored even by "allow all" filters.
---  * `transient` (table): Apps with transient or ephemeral windows not typically useful
---    for window management. Examples include Spotlight, Notification Center, and various
---    menubar apps. These are ignored by the default windowfilter but CAN be included
---    by custom filters if explicitly allowed.
---
--- Notes:
---  * Changes to `skipApps` lists after module load do NOT affect `ignoreAlways`/
---    `ignoreInDefaultFilter`. Modify those tables directly instead.
---  * For most users, the defaults work well. Only tune these if you experience specific
---    issues with performance, missing windows, or unwanted windows appearing.
---
--- Usage:
--- ```lua
--- -- Increase retry attempts for slow systems
--- hs.window.filter._config.timing.maxRetries = 10
---
--- -- Ignore a specific app by bundle ID
--- hs.window.filter._config.prefilter.ignoreBundleIDs['com.example.annoyingapp'] = true
---
--- -- Require windows to have titles before tracking
--- hs.window.filter._config.prefilter.requireTitle = true
---
--- -- Add a new app to the always-ignore list (at runtime)
--- hs.window.filter.ignoreAlways['My Background App'] = true
--- ```
local Config = {
  timing = {
    retryDelay = 0.2,
    maxRetries = 5,
    movedDebounce = 0.5,
    titleDebounce = 0.5,
    spaceChangeDelay = 0.5,
    zombieCleanupInterval = 300,
  },

  performance = {
    accessibilityTimeout = 0.5,
    skipSlowApps = false,
  },

  filtering = {
    allowedRoles = {
      AXStandardWindow = true,
      AXDialog = true,
      AXSystemDialog = true,
    },
  },

  prefilter = {
    ignoreBundleIDs = {
      ['com.apple.WebKit.WebContent'] = true,
    },
    ignoreAppPattern = '^QTKitServer%-',
    requireTitle = false,
    requireRole = false,
    minTitleLength = 0,
    allowedRoles = nil,
  },

  skipApps = {
    noPid = {
      'universalaccessd', 'sharingd', 'Safari Networking', 'Spotlight Networking',
      'iTunes Helper', 'Safari Web Content', 'App Store Web Content', 'Safari Database Storage',
      'Google Chrome Helper', 'Spotify Helper', 'Todoist Networking', 'Safari Storage',
      'Todoist Database Storage', 'AAM Updates Notifier', 'Slack Helper',
    },
    noWindows = {
      'com.apple.internetaccounts', 'CoreServicesUIAgent', 'AirPlayUIAgent',
      'com.apple.security.pboxd', 'PowerChime', 'SystemUIServer', 'Dock',
      'com.apple.dock.extra', 'storeuid', 'Folder Actions Dispatcher',
      'Keychain Circle Notification', 'Wi-Fi', 'Image Capture Extension',
      'iCloud Photos', 'System Events', 'Speech Synthesis Server',
      'Dropbox Finder Integration', 'LaterAgent', 'Karabiner_AXNotifier',
      'Photos Agent', 'EscrowSecurityAlert', 'Google Chrome Helper',
      'com.apple.MailServiceAgent', 'Safari Web Content', 'Mail Web Content',
      'Safari Networking', 'nbagent', 'rcd', 'Evernote Helper', 'BTTRelaunch',
    },
    transient = {
      'Spotlight', 'Notification Center', 'loginwindow', 'ScreenSaverEngine', 'PressAndHold',
      'PopClip', 'Isolator', 'CheatSheet', 'CornerClickBG', 'Alfred 2', 'Moom', 'CursorSense Manager',
      'Music Manager', 'Google Drive', 'Dropbox', '1Password mini', 'Colors for Hue', 'MacID',
      'CrashPlan menu bar', 'Flux', 'Jettison', 'Bartender', 'SystemPal', 'BetterSnapTool',
      'Grandview', 'Radium', 'MenuMetersApp', 'DemoPro',
    },
  },
}

-- Expose config for testing/tuning (prefixed with _ for internal use)
windowfilter._config = Config

----------------------------------------------------------------------
-- SECTION 4: UTILITY FUNCTIONS
----------------------------------------------------------------------

--- Safely call a method on an object, catching errors.
--- Returns nil if fn is nil, obj is nil, or call throws an error.
--- @param fn function The function/method to call
--- @param obj any The object to call the method on (self)
--- @param ... any Additional arguments to pass
--- @return any The result of the call, or nil on failure
local function safeCall(fn, obj, ...)
  if not fn then return nil end
  local ok, result = pcall(fn, obj, ...)
  if ok then
    return result
  else
    log.ef('safeCall failed: %s', tostring(result))
    return nil
  end
end

--- Safely get the screen ID for a window.
--- Returns 0 if window has no screen or any call fails.
--- @param hsWindow userdata The hs.window object
--- @return number The screen ID, or 0 on failure
local function safeGetScreenId(hsWindow)
  if not hsWindow then return 0 end
  local ok, scr = pcall(hsWindow.screen, hsWindow)
  if ok and scr then
    local ok2, id = pcall(scr.id, scr)
    if ok2 and id then
      return id
    end
  end
  return 0
end

-- Expose utilities for testing (prefixed with _ for internal use)
windowfilter._safeCall = safeCall
windowfilter._safeGetScreenId = safeGetScreenId

----------------------------------------------------------------------
-- SECTION 5: DATA STRUCTURES
----------------------------------------------------------------------

----------------------------------------------------------------------
-- WindowInfo: Snapshot of window state
----------------------------------------------------------------------
-- Captures window properties at a point in time with safe extraction.
-- Mutable properties can be updated via refresh().
-- appName/appPid are set by Tracker after construction.

local WindowInfo = {}
WindowInfo.__index = WindowInfo

--- Create a new WindowInfo from an hs.window object.
--- @param hsWindow userdata The hs.window object
--- @return table|nil WindowInfo object, or nil if hsWindow is invalid
function WindowInfo.new(hsWindow)
  if not hsWindow then return nil end

  local self = setmetatable({}, WindowInfo)

  -- Immutable properties (set once at creation)
  self.id = safeCall(hsWindow.id, hsWindow) or 0
  self.timeCreated = hs.timer.absoluteTime()

  -- Mutable properties (can change, updated via refresh)
  self.title = safeCall(hsWindow.title, hsWindow) or ''
  self.role = safeCall(hsWindow.subrole, hsWindow) or ''
  self.frame = safeCall(hsWindow.frame, hsWindow)
  self.screenId = safeGetScreenId(hsWindow)
  self.isMinimized = safeCall(hsWindow.isMinimized, hsWindow) or false
  self.isVisible = safeCall(hsWindow.isVisible, hsWindow) or false
  self.isFullscreen = safeCall(hsWindow.isFullScreen, hsWindow) or false

  -- hasTitlebar: true if window has a zoom button (standard window chrome)
  local zoomRect = safeCall(hsWindow.zoomButtonRect, hsWindow)
  self.hasTitlebar = zoomRect ~= nil

  -- Computed property
  self.isHidden = not self.isVisible and not self.isMinimized

  -- Tracking state (set by Tracker)
  self.timeFocused = 0
  self.appName = nil
  self.appPid = nil
  self.isInCurrentSpace = nil  -- Set by Tracker; nil means unknown

  -- Reference to underlying hs.window (for API calls)
  self._window = hsWindow

  return self
end

--- Refresh mutable properties from the underlying window.
--- Called after move/resize/title change events.
--- @return boolean true if refresh succeeded, false if window is invalid
function WindowInfo:refresh()
  local win = self._window
  if not win then return false end

  -- Check if window is still valid
  local id = safeCall(win.id, win)
  if not id or id ~= self.id then return false end

  -- Update mutable properties
  self.title = safeCall(win.title, win) or ''
  self.role = safeCall(win.subrole, win) or ''
  self.frame = safeCall(win.frame, win)
  self.screenId = safeGetScreenId(win)
  self.isMinimized = safeCall(win.isMinimized, win) or false
  self.isVisible = safeCall(win.isVisible, win) or false
  self.isFullscreen = safeCall(win.isFullScreen, win) or false

  local zoomRect = safeCall(win.zoomButtonRect, win)
  self.hasTitlebar = zoomRect ~= nil

  -- Recompute derived property
  self.isHidden = not self.isVisible and not self.isMinimized

  return true
end

--- String representation for debugging.
function WindowInfo:__tostring()
  return sformat('WindowInfo[%d]: "%s" (%s)', self.id, self.title, self.appName or '?')
end

-- Expose for testing
windowfilter._WindowInfo = WindowInfo

----------------------------------------------------------------------
-- AppInfo: Snapshot of application state
----------------------------------------------------------------------
-- Tracks application properties and its windows.
-- windows table is populated by Tracker.

local AppInfo = {}
AppInfo.__index = AppInfo

--- Create a new AppInfo from an hs.application object.
--- @param hsApp userdata The hs.application object
--- @param pid number The process ID
--- @return table|nil AppInfo object, or nil if hsApp is invalid
function AppInfo.new(hsApp, pid)
  if not hsApp then return nil end

  local self = setmetatable({}, AppInfo)

  -- Process identification
  local resolvedPid = pid or safeCall(hsApp.pid, hsApp) or 0
  -- Workaround: AXUIElementGetPid() can return -1 for stale AX elements (HSuicore.m doesn't check the return value)
  if resolvedPid <= 0 then return nil end
  self.pid = resolvedPid

  -- Application properties
  self.name = safeCall(hsApp.name, hsApp) or ''
  self.bundleID = safeCall(hsApp.bundleID, hsApp) or ''
  self.isHidden = safeCall(hsApp.isHidden, hsApp) or false
  self.isFrontmost = safeCall(hsApp.isFrontmost, hsApp) or false

  -- Windows tracked for this app (id -> WindowInfo)
  -- Populated by Tracker, not here
  self.windows = {}

  -- Watcher for this app's UI events (set by Tracker)
  self.watcher = nil

  -- Reference to underlying hs.application
  self._app = hsApp

  return self
end

--- Refresh application state properties.
--- @return boolean true if refresh succeeded, false if app is invalid
function AppInfo:refresh()
  local app = self._app
  if not app then return false end

  -- Check if app is still running
  local pid = safeCall(app.pid, app)
  if not pid or pid ~= self.pid then return false end

  self.isHidden = safeCall(app.isHidden, app) or false
  self.isFrontmost = safeCall(app.isFrontmost, app) or false

  return true
end

--- String representation for debugging.
function AppInfo:__tostring()
  local winCount = 0
  for _ in pairs(self.windows) do winCount = winCount + 1 end
  return sformat('AppInfo[%d]: %s (%d windows)', self.pid, self.name, winCount)
end

-- Expose for testing
windowfilter._AppInfo = AppInfo

----------------------------------------------------------------------
-- SECTION 6: FILTER RULES AND FILTER
----------------------------------------------------------------------

----------------------------------------------------------------------
-- FilterRules: Storage for filter configuration
----------------------------------------------------------------------
-- Stores override, per-app, and default filter rules.
-- Each rule is either false (reject all) or a table of criteria.

local FilterRules = {}
FilterRules.__index = FilterRules

--- Create a new FilterRules object.
--- @return table FilterRules object
function FilterRules.new()
  local self = setmetatable({}, FilterRules)
  self.override = nil       -- Applied first to all windows; false = reject all
  self.appRules = {}        -- appname -> rule table or false
  self.default = nil        -- Fallback rule; false = reject all
  return self
end

--- String representation for debugging.
function FilterRules:__tostring()
  local appCount = 0
  for _ in pairs(self.appRules) do appCount = appCount + 1 end
  return sformat('FilterRules: override=%s, apps=%d, default=%s',
    tostring(self.override ~= nil), appCount, tostring(self.default ~= nil))
end

-- Expose for testing
windowfilter._FilterRules = FilterRules

----------------------------------------------------------------------
-- Filter: Pure functions for matching windows against rules
----------------------------------------------------------------------
-- All matching logic is stateless and side-effect free.
-- Context is passed explicitly to avoid global state.

local Filter = {}

--- Match a window against a complete FilterRules structure.
--- Checks override, then app-specific, then default rules.
--- @param rules table FilterRules object
--- @param windowInfo table WindowInfo object
--- @param context table {focusedWindowId, activeAppPid}
--- @return boolean allowed, string reason
function Filter.matches(rules, windowInfo, context)
  if not rules then return true, '' end
  if not windowInfo then return false, 'nil windowInfo' end

  local appName = windowInfo.appName or ''

  -- Check override filter (applied to all windows)
  if rules.override == false then
    return false, 'override rejects all'
  end
  if rules.override then
    local ok, reason = Filter.matchesRule(rules.override, windowInfo, context)
    if not ok then
      return false, 'override: ' .. reason
    end
  end

  -- Check app-specific filter
  local appRule = rules.appRules[appName]
  if appRule == false then
    return false, 'app rejected'
  end
  if appRule then
    local ok, reason = Filter.matchesRule(appRule, windowInfo, context)
    return ok, ok and '' or ('app: ' .. reason)
  end

  -- Check default filter
  if rules.default == false then
    return false, 'default rejects all'
  end
  if rules.default then
    local ok, reason = Filter.matchesRule(rules.default, windowInfo, context)
    return ok, ok and '' or ('default: ' .. reason)
  end

  -- No filter = allow
  return true, ''
end

--- Match a window against a single rule table.
--- @param rule table Rule with filter criteria
--- @param windowInfo table WindowInfo object
--- @param context table {focusedWindowId, activeAppPid}
--- @return boolean allowed, string reason
function Filter.matchesRule(rule, windowInfo, context)
  -- Handle boolean rules: true = allow all, false/nil = allow all (no restrictions)
  if type(rule) == 'boolean' then
    return rule, rule and '' or 'rejected'
  end
  if not rule then return true, '' end
  context = context or {}

  -- Visibility
  if rule.visible ~= nil then
    if rule.visible ~= windowInfo.isVisible then
      return false, 'visible'
    end
  end

  -- Current space
  if rule.currentSpace ~= nil then
    if rule.currentSpace ~= windowInfo.isInCurrentSpace then
      return false, 'currentSpace'
    end
  end

  -- Fullscreen
  if rule.fullscreen ~= nil then
    if rule.fullscreen ~= windowInfo.isFullscreen then
      return false, 'fullscreen'
    end
  end

  -- Focused
  if rule.focused ~= nil then
    local isFocused = (windowInfo.id == context.focusedWindowId)
    if rule.focused ~= isFocused then
      return false, 'focused'
    end
  end

  -- Active application
  if rule.activeApplication ~= nil then
    local isActive = (windowInfo.appPid == context.activeAppPid)
    if rule.activeApplication ~= isActive then
      return false, 'activeApplication'
    end
  end

  -- Allow titles (minimum length or pattern match)
  if rule.allowTitles then
    if not Filter.matchesTitleRule(rule.allowTitles, windowInfo.title) then
      return false, 'allowTitles'
    end
  end

  -- Reject titles (pattern match)
  if rule.rejectTitles then
    if Filter.matchesTitlePattern(rule.rejectTitles, windowInfo.title) then
      return false, 'rejectTitles'
    end
  end

  -- Titlebar
  if rule.hasTitlebar ~= nil then
    if rule.hasTitlebar ~= windowInfo.hasTitlebar then
      return false, 'hasTitlebar'
    end
  end

  -- Roles (check subrole against allowed list)
  local allowedRoles = rule.allowRoles or windowfilter.allowedWindowRoles or Config.filtering.allowedRoles
  if allowedRoles ~= '*' then
    if type(allowedRoles) == 'string' then
      allowedRoles = {[allowedRoles] = true}
    elseif type(allowedRoles) == 'table' and allowedRoles[1] then
      -- Convert array to set
      local roleSet = {}
      for _, r in ipairs(allowedRoles) do roleSet[r] = true end
      allowedRoles = roleSet
    end
    if not allowedRoles[windowInfo.role] then
      return false, 'allowRoles'
    end
  end

  -- Regions and screens only apply to visible windows
  if windowInfo.isVisible then
    -- Allow regions (window must be in at least one region)
    if rule.allowRegions then
      if not Filter.matchesRegions(rule.allowRegions, windowInfo.frame) then
        return false, 'allowRegions'
      end
    end

    -- Reject regions (window must NOT be in any region)
    -- NOTE: Fixed bug from original - was using allowRegions instead of rejectRegions
    if rule.rejectRegions then
      if Filter.matchesRegions(rule.rejectRegions, windowInfo.frame) then
        return false, 'rejectRegions'
      end
    end

    -- Allow screens (window must be on at least one screen)
    if rule.allowScreens then
      local allowedScreenIds = Filter.resolveScreens(rule.allowScreens)
      if not allowedScreenIds[windowInfo.screenId] then
        return false, 'allowScreens'
      end
    end

    -- Reject screens (window must NOT be on any screen)
    if rule.rejectScreens then
      local rejectedScreenIds = Filter.resolveScreens(rule.rejectScreens)
      if rejectedScreenIds[windowInfo.screenId] then
        return false, 'rejectScreens'
      end
    end
  end

  return true, ''
end

--- Match title against allowTitles rule.
--- If rule is a number, checks minimum title length.
--- Otherwise delegates to pattern matching.
--- @param rule number|string|table The allowTitles rule
--- @param title string The window title
--- @return boolean true if title matches rule
function Filter.matchesTitleRule(rule, title)
  if type(rule) == 'number' then
    return #title >= rule
  end
  return Filter.matchesTitlePattern(rule, title)
end

--- Match title against pattern(s).
--- @param patterns string|table Pattern or list of patterns
--- @param title string The window title
--- @return boolean true if title matches any pattern
function Filter.matchesTitlePattern(patterns, title)
  if type(patterns) == 'string' then
    patterns = {patterns}
  end
  if type(patterns) ~= 'table' then
    return false
  end
  for _, pattern in ipairs(patterns) do
    if smatch(title, pattern) then
      return true
    end
  end
  return false
end

--- Match window frame against regions using 50% overlap rule.
--- Window matches if:
---   - More than 50% of window is inside a region, OR
---   - More than 50% of a region is covered by the window
--- @param regions table List of hs.geometry rects
--- @param frame table Window frame (hs.geometry rect)
--- @return boolean true if window matches any region
function Filter.matchesRegions(regions, frame)
  if not regions or not frame then return false end
  if type(regions) ~= 'table' then
    regions = {regions}
  end
  -- Ensure regions is a list (might be single rect)
  if regions.x ~= nil then
    regions = {regions}
  end

  for _, region in ipairs(regions) do
    -- Use hs.geometry intersection
    local intersection = frame:intersect(region)
    if intersection and intersection.area and intersection.area > 0 then
      local frameArea = frame.area or (frame.w * frame.h)
      local regionArea = region.area or (region.w * region.h)
      if frameArea > 0 and regionArea > 0 then
        -- Check 50% overlap rule
        if intersection.area > frameArea * 0.5 or intersection.area > regionArea * 0.5 then
          return true
        end
      end
    end
  end
  return false
end

--- Resolve screen hints to screen IDs.
--- Resolved lazily at match time for hot-plug reliability.
--- @param screenHints any Valid argument(s) for hs.screen.find()
--- @return table Set of screen IDs {[id] = true}
function Filter.resolveScreens(screenHints)
  local ids = {}
  if screenHints == nil then return ids end

  -- Normalize to list
  if type(screenHints) ~= 'table' or screenHints.id then
    -- Single screen or screen hint
    screenHints = {screenHints}
  end

  for _, hint in ipairs(screenHints) do
    local scr = nil
    -- If hint is already a screen object, use it directly
    if type(hint) == 'userdata' or (type(hint) == 'table' and hint.id) then
      scr = hint
    else
      -- Use hs.screen.find to resolve hint
      local ok, result = pcall(hs.screen.find, hint)
      if ok then scr = result end
    end

    if scr then
      local ok, id = pcall(scr.id, scr)
      if ok and id then
        ids[id] = true
      end
    end
  end

  return ids
end

----------------------------------------------------------------------
-- Filter Instance Methods
----------------------------------------------------------------------
-- These methods allow Filter to be used as an instance with stored rules.

-- Save reference to the static matches function before we shadow it
local Filter_matchesStatic = Filter.matches

Filter.__index = Filter

--- Create a new Filter instance.
--- @return table Filter instance with empty rules
function Filter.new()
  local self = setmetatable({}, Filter)
  self._rules = FilterRules.new()
  return self
end

--- Set filter rules for a specific app.
--- @param appName string Application name
--- @param rules boolean|table Filter rules (true=allow, false=reject, table=detailed rules)
function Filter:setAppFilter(appName, rules)
  if type(rules) == 'boolean' then
    self._rules.appRules[appName] = rules
  elseif type(rules) == 'table' then
    self._rules.appRules[appName] = rules
  else
    self._rules.appRules[appName] = nil
  end
end

--- Set the default filter for apps without specific rules.
--- @param rules boolean|table Filter rules
function Filter:setDefaultFilter(rules)
  if rules == true then
    self._rules.default = {}  -- Empty table means "allow with no restrictions"
  elseif rules == false then
    self._rules.default = false
  elseif type(rules) == 'table' then
    self._rules.default = rules
  else
    self._rules.default = nil
  end
end

--- Set the override filter that applies to all windows.
--- @param rules boolean|table Filter rules
function Filter:setOverrideFilter(rules)
  if rules == true then
    self._rules.override = {}  -- Allow all
  elseif rules == false then
    self._rules.override = false
  elseif type(rules) == 'table' then
    self._rules.override = rules
  else
    self._rules.override = nil
  end
end

--- Get current filter configuration.
--- @return table Filter rules
function Filter:getFilters()
  local result = {}
  if self._rules.default ~= nil then
    result.default = self._rules.default
  end
  if self._rules.override ~= nil then
    result.override = self._rules.override
  end
  for appName, rules in pairs(self._rules.appRules) do
    result[appName] = rules
  end
  return result
end

--- Check if an app is allowed by this filter.
--- @param appName string Application name
--- @return boolean
function Filter:isAppAllowed(appName)
  -- Check if app is explicitly rejected
  if self._rules.appRules[appName] == false then
    return false
  end
  -- Check if app has rules (meaning it's allowed)
  if self._rules.appRules[appName] then
    return true
  end
  -- Check default
  if self._rules.default == false then
    return false
  end
  -- Default allows
  return true
end

--- Match a window against this filter's rules (instance method).
--- @param windowInfo table WindowInfo object
--- @param appInfo table|nil AppInfo object
--- @param context table {focusedWindowId, activeAppPid}
--- @return boolean allowed
function Filter:matchWindow(windowInfo, appInfo, context)
  local ok, _ = Filter_matchesStatic(self._rules, windowInfo, context)
  return ok
end

--- Create a copy of this filter.
--- @return table New Filter with same rules
function Filter:copy()
  local new = Filter.new()
  new._rules.default = self._rules.default
  new._rules.override = self._rules.override
  for appName, rules in pairs(self._rules.appRules) do
    if type(rules) == 'table' then
      -- Deep copy rule table
      local copy = {}
      for k, v in pairs(rules) do copy[k] = v end
      new._rules.appRules[appName] = copy
    else
      new._rules.appRules[appName] = rules
    end
  end
  return new
end

-- Expose for testing
windowfilter._Filter = Filter

----------------------------------------------------------------------
-- SECTION 7: PREFILTER
----------------------------------------------------------------------
-- PreFilter decides whether to create watchers for apps/windows.
-- This is a performance optimization - avoids tracking non-GUI apps
-- and windows that will never match any filter.
-- All functions are pure and take config as parameter.

local PreFilter = {}

--- Check if an app should be tracked (watcher created).
--- Called by Tracker when a new app is detected.
--- @param hsApp userdata The hs.application object
--- @param config table PreFilter configuration
--- @return boolean shouldTrack, string reason (if false)
function PreFilter.shouldTrackApp(hsApp, config)
  if not hsApp then return false, 'nil app' end
  config = config or {}

  -- Check app:kind() - negative means no GUI
  local kind = safeCall(hsApp.kind, hsApp)
  if kind and kind < 0 then
    return false, 'not a GUI app'
  end

  local appName = safeCall(hsApp.name, hsApp) or ''
  local bundleID = safeCall(hsApp.bundleID, hsApp) or ''

  -- Check bundle ID blacklist
  if config.ignoreBundleIDs and bundleID ~= '' then
    if config.ignoreBundleIDs[bundleID] then
      return false, 'bundleID blacklisted'
    end
  end

  -- Check app name blacklist
  if config.ignoreAppNames and appName ~= '' then
    if config.ignoreAppNames[appName] then
      return false, 'appName blacklisted'
    end
  end

  -- Check app name pattern (e.g., '^QTKitServer%-')
  if config.ignoreAppPattern and appName ~= '' then
    if smatch(appName, config.ignoreAppPattern) then
      return false, 'appName matches ignore pattern'
    end
  end

  -- Blacklist browser helper processes (e.g., "Safari Web Content", "Chrome Web Content")
  if appName ~= '' and smatch(appName, 'Web Content$') then
    return false, 'Web Content helper process'
  end

  return true, nil
end

--- Check if a window should be tracked (watcher created).
--- Called by Tracker when a new window is detected.
--- Assumes app has already passed shouldTrackApp.
--- @param hsWindow userdata The hs.window object
--- @param hsApp userdata The hs.application object (for context, not re-checked)
--- @param config table PreFilter configuration
--- @return boolean shouldTrack, string reason (if false)
function PreFilter.shouldTrack(hsWindow, hsApp, config)
  if not hsWindow then return false, 'nil window' end
  config = config or {}

  -- Get window properties
  local title = safeCall(hsWindow.title, hsWindow) or ''
  local role = safeCall(hsWindow.subrole, hsWindow) or ''

  -- Check title requirements
  if config.requireTitle and #title == 0 then
    return false, 'empty title'
  end

  if config.minTitleLength and config.minTitleLength > 0 then
    if #title < config.minTitleLength then
      return false, 'title too short'
    end
  end

  -- Check role requirements
  if config.requireRole and #role == 0 then
    return false, 'empty role'
  end

  if config.allowedRoles then
    if type(config.allowedRoles) == 'table' then
      if not config.allowedRoles[role] then
        return false, 'role not allowed'
      end
    end
  end

  return true, nil
end

----------------------------------------------------------------------
-- Ignore Lists (built from Config.skipApps)
----------------------------------------------------------------------

-- Build the ignoreAlways table (apps always ignored)
-- Combines noPid and noWindows lists from Config.skipApps
local ignoreAlways = {}
for _, list in ipairs({Config.skipApps.noPid, Config.skipApps.noWindows}) do
  for _, appname in ipairs(list) do
    ignoreAlways[appname] = true
  end
end

-- Build the ignoreInDefaultFilter table (apps ignored in default filter only)
local ignoreInDefaultFilter = {}
for _, appname in ipairs(Config.skipApps.transient) do
  ignoreInDefaultFilter[appname] = true
end

--- hs.window.filter.ignoreAlways
--- Variable
--- A table of application names (as per `hs.application:name()`) that are always ignored by this module.
--- These are apps with no windows or any visible GUI, such as system services, background daemons and "helper" apps.
---
--- You can add an app to this table with `hs.window.filter.ignoreAlways['Background App Title'] = true`
---
--- Notes:
---  * As the name implies, even the empty, "allow all" windowfilter will ignore these apps.
---  * You don't *need* to keep this table up to date, since non GUI apps will simply never show up anywhere;
---    this table is just used as a "root" filter to gain a (very small) performance improvement.
windowfilter.ignoreAlways = ignoreAlways

--- hs.window.filter.ignoreInDefaultFilter
--- Variable
--- A table of application names that are ignored by the default windowfilter.
--- These are apps with transient windows that are usually not interesting for window management.
---
--- You can add an app to this table with `hs.window.filter.ignoreInDefaultFilter['Menubar App'] = true`
windowfilter.ignoreInDefaultFilter = ignoreInDefaultFilter

----------------------------------------------------------------------

--- Create a default PreFilter configuration.
--- Returns a fresh copy of the config to avoid shared state issues.
--- Values are sourced from Config.prefilter for centralized configuration.
--- @return table Default config
function PreFilter.defaultConfig()
  -- Copy ignoreBundleIDs from Config to avoid shared state modification
  local ignoreBundleIDsCopy = {}
  for k, v in pairs(Config.prefilter.ignoreBundleIDs) do
    ignoreBundleIDsCopy[k] = v
  end

  -- Copy ignoreAlways to avoid shared state modification
  local ignoreAppNamesCopy = {}
  for k, v in pairs(ignoreAlways) do
    ignoreAppNamesCopy[k] = v
  end

  return {
    ignoreBundleIDs = ignoreBundleIDsCopy,
    ignoreAppNames = ignoreAppNamesCopy,  -- Dynamic: built from public ignoreAlways table
    ignoreAppPattern = Config.prefilter.ignoreAppPattern,
    requireTitle = Config.prefilter.requireTitle,
    requireRole = Config.prefilter.requireRole,
    minTitleLength = Config.prefilter.minTitleLength,
    allowedRoles = Config.prefilter.allowedRoles,
  }
end

-- Expose for testing
windowfilter._PreFilter = PreFilter

----------------------------------------------------------------------
-- SECTION 8: EVENTS AND SUBSCRIPTIONS
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Event Constants
----------------------------------------------------------------------

--- hs.window.filter.windowCreated
--- Constant
--- Event for `hs.window.filter:subscribe()`: a new window was created
windowfilter.windowCreated = 'windowCreated'

--- hs.window.filter.windowDestroyed
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was destroyed
windowfilter.windowDestroyed = 'windowDestroyed'

--- hs.window.filter.windowMoved
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was moved or resized, including toggling fullscreen/maximize
windowfilter.windowMoved = 'windowMoved'

--- hs.window.filter.windowFullscreened
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was expanded to fullscreen
windowfilter.windowFullscreened = 'windowFullscreened'

--- hs.window.filter.windowUnfullscreened
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was reverted back from fullscreen
windowfilter.windowUnfullscreened = 'windowUnfullscreened'

--- hs.window.filter.windowMinimized
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was minimized
windowfilter.windowMinimized = 'windowMinimized'

--- hs.window.filter.windowUnminimized
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was unminimized
windowfilter.windowUnminimized = 'windowUnminimized'

--- hs.window.filter.windowUnhidden
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was unhidden (its app was unhidden, e.g. via `cmd-h`)
windowfilter.windowUnhidden = 'windowUnhidden'

--- hs.window.filter.windowHidden
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window was hidden (its app was hidden, e.g. via `cmd-h`)
windowfilter.windowHidden = 'windowHidden'

--- hs.window.filter.windowVisible
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window became "visible" (in *any* Mission Control Space, as per `hs.window:isVisible()`)
--- after having been hidden or minimized, or if it was just created
windowfilter.windowVisible = 'windowVisible'

--- hs.window.filter.windowNotVisible
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window is no longer "visible" (in *any* Mission Control Space, as per `hs.window:isVisible()`)
--- because it was minimized or closed, or its application was hidden (e.g. via `cmd-h`) or closed
windowfilter.windowNotVisible = 'windowNotVisible'

--- hs.window.filter.windowInCurrentSpace
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window is now in the current Mission Control Space, due to
--- a Space switch or because it was hidden or minimized (hidden and minimized windows belong to all Spaces)
windowfilter.windowInCurrentSpace = 'windowInCurrentSpace'

--- hs.window.filter.windowNotInCurrentSpace
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window that used to be in the current Mission Control Space isn't anymore,
--- due to a Space switch or because it was unhidden or unminimized onto another Space
windowfilter.windowNotInCurrentSpace = 'windowNotInCurrentSpace'

--- hs.window.filter.windowOnScreen
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window became *actually* visible on screen (i.e. it's "visible" as per `hs.window:isVisible()`
--- *and* in the current Mission Control Space) after having been not visible, or when created
windowfilter.windowOnScreen = 'windowOnScreen'

--- hs.window.filter.windowNotOnScreen
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window is no longer *actually* visible on any screen because it was minimized, closed,
--- its application was hidden (e.g. via cmd-h) or closed, or because it's not in the current Mission Control Space anymore
windowfilter.windowNotOnScreen = 'windowNotOnScreen'

--- hs.window.filter.windowFocused
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window received focus
windowfilter.windowFocused = 'windowFocused'

--- hs.window.filter.windowUnfocused
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window lost focus
windowfilter.windowUnfocused = 'windowUnfocused'

--- hs.window.filter.windowTitleChanged
--- Constant
--- Event for `hs.window.filter:subscribe()`: a window's title changed
windowfilter.windowTitleChanged = 'windowTitleChanged'

--- hs.window.filter.windowAllowed
--- Constant
--- Pseudo-event for `hs.window.filter:subscribe()`: a previously rejected window (or a newly created one) is now allowed
---
--- Notes:
---  * this pseudo-event will be emitted *before* the *actual* event(s) (e.g. `windowCreated`) that caused the window to be allowed
windowfilter.windowAllowed = 'windowAllowed'

--- hs.window.filter.windowRejected
--- Constant
--- Pseudo-event for `hs.window.filter:subscribe()`: a previously allowed window (or a window that's been destroyed) is now rejected
---
--- Notes:
---  * this pseudo-event will be emitted *after* the *actual* event(s) (e.g. `windowDestroyed`) that caused the window to be rejected
windowfilter.windowRejected = 'windowRejected'

--- hs.window.filter.hasWindow
--- Constant
--- Pseudo-event for `hs.window.filter:subscribe()`: the windowfilter now allows one window
---
--- Notes:
---  * callbacks for this event will receive (as the first argument) the window that is now allowed
---  * this pseudo-event won't trigger again until after the windowfilter reverts to rejecting all windows
---  * this pseudo-event will be emitted *after* the *actual* event(s) (e.g. `windowCreated`) that caused a window to be allowed
windowfilter.hasWindow = 'hasWindow'

--- hs.window.filter.hasNoWindows
--- Constant
--- Pseudo-event for `hs.window.filter:subscribe()`: the windowfilter now rejects all windows
---
--- Notes:
---  * callbacks for this event will receive (as the first argument) the last window that was allowed (and is now rejected)
---  * this pseudo-event won't trigger again until after the windowfilter allows at least one window
---  * this pseudo-event will be emitted *after* the *actual* event(s) (e.g. `windowDestroyed`) that caused the window to be rejected
windowfilter.hasNoWindows = 'hasNoWindows'

--- hs.window.filter.windowsChanged
--- Constant
--- Pseudo-event for `hs.window.filter:subscribe()`: the list of allowed windows (as per `windowfilter:getWindows()`) has changed
---
--- Notes:
---  * callbacks for this event will receive (as the first argument) either a random window among the currently allowed ones,
---    or nil if the windowfilter is rejecting all windows
---  * similarly, the second argument passed to callbacks (window's app name) will be nil if the windowfilter is rejecting all windows
---  * this pseudo-event will be emitted *after* the *actual* event(s) that caused the list of allowed windows to change
windowfilter.windowsChanged = 'windowsChanged'

-- Set of all valid events for validation
local validEvents = {
  [windowfilter.windowCreated] = true,
  [windowfilter.windowDestroyed] = true,
  [windowfilter.windowMoved] = true,
  [windowfilter.windowFullscreened] = true,
  [windowfilter.windowUnfullscreened] = true,
  [windowfilter.windowMinimized] = true,
  [windowfilter.windowUnminimized] = true,
  [windowfilter.windowUnhidden] = true,
  [windowfilter.windowHidden] = true,
  [windowfilter.windowVisible] = true,
  [windowfilter.windowNotVisible] = true,
  [windowfilter.windowInCurrentSpace] = true,
  [windowfilter.windowNotInCurrentSpace] = true,
  [windowfilter.windowOnScreen] = true,
  [windowfilter.windowNotOnScreen] = true,
  [windowfilter.windowFocused] = true,
  [windowfilter.windowUnfocused] = true,
  [windowfilter.windowTitleChanged] = true,
  [windowfilter.windowAllowed] = true,
  [windowfilter.windowRejected] = true,
  [windowfilter.hasWindow] = true,
  [windowfilter.hasNoWindows] = true,
  [windowfilter.windowsChanged] = true,
}

--- Check if an event name is valid.
--- @param event string The event name to check
--- @return boolean true if valid
local function isValidEvent(event)
  return validEvents[event] == true
end

-- Expose for testing
windowfilter._validEvents = validEvents
windowfilter._isValidEvent = isValidEvent

----------------------------------------------------------------------
-- Sort Order Constants
----------------------------------------------------------------------

--- hs.window.filter.sortByFocusedLast
--- Constant
--- Sort order for `hs.window.filter:getWindows()`: windows are sorted in order of focus received, most recently first (see also `hs.window.filter:setSortOrder()`)
---
--- Notes:
---  * This is the default sort order for all windowfilters
windowfilter.sortByFocusedLast = 'focusedLast'

--- hs.window.filter.sortByFocused
--- Constant
--- Sort order for `hs.window.filter:getWindows()`: windows are sorted in order of focus received, least recently first (see also `hs.window.filter:setSortOrder()`)
windowfilter.sortByFocused = 'focused'

--- hs.window.filter.sortByCreatedLast
--- Constant
--- Sort order for `hs.window.filter:getWindows()`: windows are sorted in order of creation, newest first (see also `hs.window.filter:setSortOrder()`)
windowfilter.sortByCreatedLast = 'createdLast'

--- hs.window.filter.sortByCreated
--- Constant
--- Sort order for `hs.window.filter:getWindows()`: windows are sorted in order of creation, oldest first (see also `hs.window.filter:setSortOrder()`)
windowfilter.sortByCreated = 'created'

----------------------------------------------------------------------
-- Subscriptions: Callback storage and emission
----------------------------------------------------------------------
-- Manages event subscriptions for a single windowfilter instance.
-- Callbacks are stored as sets per event for O(1) add/remove.
-- Emission uses pcall to protect against callback errors.

local Subscriptions = {}
Subscriptions.__index = Subscriptions

--- Create a new Subscriptions object.
--- @return table Subscriptions object
function Subscriptions.new()
  local self = setmetatable({}, Subscriptions)
  self.callbacks = {}  -- event -> { [fn] = true }
  return self
end

--- Add a callback for an event.
--- @param event string The event name (must be a valid event constant)
--- @param fn function The callback function
--- @return boolean true if added, false if already existed
function Subscriptions:add(event, fn)
  -- Validate event
  if not isValidEvent(event) then
    error(sformat('invalid event: %s', tostring(event)), 2)
  end
  -- Validate callback
  if type(fn) ~= 'function' then
    error(sformat('callback must be a function, got %s', type(fn)), 2)
  end

  -- Create event table if needed
  if not self.callbacks[event] then
    self.callbacks[event] = {}
  end

  -- Check for duplicate
  if self.callbacks[event][fn] then
    return false
  end

  self.callbacks[event][fn] = true
  return true
end

--- Remove a callback for an event.
--- @param event string The event name
--- @param fn function The callback function to remove
--- @return boolean true if removed, false if not found
function Subscriptions:remove(event, fn)
  if not self.callbacks[event] then
    return false
  end

  if not self.callbacks[event][fn] then
    return false
  end

  self.callbacks[event][fn] = nil

  -- Clean up empty event table
  if not next(self.callbacks[event]) then
    self.callbacks[event] = nil
  end

  return true
end

--- Remove all callbacks for a specific event, or all callbacks if event is nil.
--- @param event string|nil The event name, or nil to remove all
--- @return number The number of callbacks removed
function Subscriptions:removeAll(event)
  local count = 0

  if event then
    -- Remove all for specific event
    if self.callbacks[event] then
      for _ in pairs(self.callbacks[event]) do
        count = count + 1
      end
      self.callbacks[event] = nil
    end
  else
    -- Remove all callbacks
    for ev, fns in pairs(self.callbacks) do
      for _ in pairs(fns) do
        count = count + 1
      end
    end
    self.callbacks = {}
  end

  return count
end

--- Emit an event to all subscribed callbacks.
--- Callbacks receive (window, appName, event) as arguments.
--- Errors in callbacks are caught and logged, but don't stop other callbacks.
--- @param event string The event name
--- @param window userdata The hs.window object
--- @param appName string The application name
--- @return number The number of callbacks called
function Subscriptions:emit(event, window, appName)
  local fns = self.callbacks[event]
  if not fns then return 0 end

  local count = 0

  -- Iterate over a snapshot of callbacks to handle removal during emit
  local callbackList = {}
  for fn in pairs(fns) do
    tinsert(callbackList, fn)
  end

  for _, fn in ipairs(callbackList) do
    -- Only call if still subscribed (might have been removed by earlier callback)
    if fns[fn] then
      local ok, err = pcall(fn, window, appName, event)
      if not ok then
        log.ef('callback error for %s: %s', event, tostring(err))
      end
      count = count + 1
    end
  end

  return count
end

--- Check if there are any callbacks registered.
--- @return boolean true if at least one callback exists
function Subscriptions:hasAny()
  return next(self.callbacks) ~= nil
end

--- Check if there are callbacks for a specific event.
--- @param event string The event name
--- @return boolean true if callbacks exist for this event
function Subscriptions:hasEvent(event)
  return self.callbacks[event] ~= nil and next(self.callbacks[event]) ~= nil
end

--- Get the count of callbacks for an event, or total if event is nil.
--- @param event string|nil The event name, or nil for total count
--- @return number The callback count
function Subscriptions:count(event)
  if event then
    if not self.callbacks[event] then return 0 end
    local n = 0
    for _ in pairs(self.callbacks[event]) do n = n + 1 end
    return n
  else
    local n = 0
    for _, fns in pairs(self.callbacks) do
      for _ in pairs(fns) do n = n + 1 end
    end
    return n
  end
end

--- String representation for debugging.
function Subscriptions:__tostring()
  local eventCount = 0
  local totalCallbacks = 0
  for _, fns in pairs(self.callbacks) do
    eventCount = eventCount + 1
    for _ in pairs(fns) do totalCallbacks = totalCallbacks + 1 end
  end
  return sformat('Subscriptions: %d events, %d callbacks', eventCount, totalCallbacks)
end

-- Expose for testing
windowfilter._Subscriptions = Subscriptions

----------------------------------------------------------------------
-- SECTION 9: TRACKER
----------------------------------------------------------------------
-- Tracker manages watchers for apps and windows, reporting raw events
-- to the Manager. It handles:
-- - App lifecycle (launched, terminated, activated, deactivated, hidden, unhidden)
-- - Window lifecycle (created, destroyed, moved, minimized, etc.)
-- - Retry logic for apps/windows that aren't ready yet
-- - Debouncing for move/title events
-- - Zombie cleanup

-- UI element watcher event constants (from hs.uielement.watcher)
local uiwatcher = hs.uielement.watcher

-- Application watcher event constants (from hs.application.watcher)
local appwatcher = hs.application.watcher

----------------------------------------------------------------------
-- ManagerStub: Minimal stub for testing Tracker in isolation
----------------------------------------------------------------------
-- Implements the Manager interface with logging/counting for tests.
-- Real Manager (Step 7) will replace this.

local ManagerStub = {}
ManagerStub.__index = ManagerStub

function ManagerStub.new()
  local self = setmetatable({}, ManagerStub)
  self.events = {}  -- List of {event, args} for verification
  self.preFilter = PreFilter.defaultConfig()
  return self
end

function ManagerStub:_record(event, ...)
  table.insert(self.events, {event = event, args = {...}})
end

function ManagerStub:onWindowCreated(windowInfo, appInfo)
  self:_record('windowCreated', windowInfo, appInfo)
end

function ManagerStub:onWindowDestroyed(windowInfo, appInfo)
  self:_record('windowDestroyed', windowInfo, appInfo)
end

function ManagerStub:onWindowMoved(windowInfo, appInfo)
  self:_record('windowMoved', windowInfo, appInfo)
end

function ManagerStub:onWindowMinimized(windowInfo, appInfo)
  self:_record('windowMinimized', windowInfo, appInfo)
end

function ManagerStub:onWindowUnminimized(windowInfo, appInfo)
  self:_record('windowUnminimized', windowInfo, appInfo)
end

function ManagerStub:onWindowTitleChanged(windowInfo, appInfo)
  self:_record('windowTitleChanged', windowInfo, appInfo)
end

function ManagerStub:onAppActivated(appInfo)
  self:_record('appActivated', appInfo)
end

function ManagerStub:onAppDeactivated(appInfo)
  self:_record('appDeactivated', appInfo)
end

function ManagerStub:onAppHidden(appInfo)
  self:_record('appHidden', appInfo)
end

function ManagerStub:onAppUnhidden(appInfo)
  self:_record('appUnhidden', appInfo)
end

function ManagerStub:onFocusChanged(windowInfo, appInfo, prevWindowInfo)
  self:_record('focusChanged', windowInfo, appInfo, prevWindowInfo)
end

function ManagerStub:getEventCount(eventName)
  local count = 0
  for _, e in ipairs(self.events) do
    if e.event == eventName then count = count + 1 end
  end
  return count
end

function ManagerStub:getLastEvent(eventName)
  for i = #self.events, 1, -1 do
    if self.events[i].event == eventName then
      return self.events[i]
    end
  end
  return nil
end

function ManagerStub:clearEvents()
  self.events = {}
end

-- Expose for testing
windowfilter._ManagerStub = ManagerStub

----------------------------------------------------------------------
-- Tracker: Manages watchers and reports events to Manager
----------------------------------------------------------------------

local Tracker = {}
Tracker.__index = Tracker

--- Create a new Tracker.
--- @param manager table Object implementing Manager interface
--- @return table Tracker instance
function Tracker.new(manager)
  local self = setmetatable({}, Tracker)

  self.manager = manager
  self.apps = {}              -- pid -> AppInfo
  self.appWatcher = nil       -- hs.application.watcher
  self.pendingApps = {}       -- pid -> {timer, retryCount}
  self.pendingWindows = {}    -- window userdata -> {timer, retryCount, appInfo}
  self.movedTimers = {}       -- windowId -> timer (debounce)
  self.titleTimers = {}       -- windowId -> timer (debounce)
  self.running = false
  self.focusedWindowId = nil  -- Track for focus change detection
  self.prevFocusedWindowId = nil  -- Track previous for deactivated handler
  self.focusedAppPid = nil

  return self
end

--- Start tracking apps and windows.
function Tracker:start()
  if self.running then return end
  self.running = true

  -- Create app watcher
  self.appWatcher = hs.application.watcher.new(function(name, event, app)
    self:_onAppEvent(name, event, app)
  end)

  -- Register existing apps
  local runningApps = hs.application.runningApplications()
  for _, app in ipairs(runningApps) do
    self:registerApp(app)
  end

  -- Bootstrap z-order timestamps for pre-existing windows.
  -- hs.window._orderedwinids() returns window IDs sorted by z-index (frontmost first).
  -- We assign synthetic timeFocused/timeCreated values that preserve this ordering,
  -- matching the original window_filter.lua behavior so that directional functions
  -- (windowsToWest, windowsToEast, etc.) get correct z-order information.
  local ids = hs.window._orderedwinids()
  local time = timer.secondsSinceEpoch()
  preexistingWindowTimestamps = {}
  for i, id in ipairs(ids) do
    preexistingWindowTimestamps[id] = {
      timeFocused = time - i,
      timeCreated = time + id - 999999,
    }
  end

  -- Start watching for new apps
  self.appWatcher:start()

  -- Clear z-order bootstrap data after initial window registration is done.
  -- All synchronous windowCreated events have already been dispatched above,
  -- but use a short delay to cover any async retries.
  hs.timer.doAfter(5, function() preexistingWindowTimestamps = nil end)

  -- Start periodic zombie cleanup
  local interval = windowfilter._config.timing.zombieCleanupInterval
  self.zombieTimer = timer.new(interval, function() self:cleanupZombies() end)
  self.zombieTimer:start()

  log.i('Tracker started')
end

--- Stop tracking and clean up all watchers.
function Tracker:stop()
  if not self.running then return end
  self.running = false
  preexistingWindowTimestamps = nil

  -- Stop zombie cleanup timer
  if self.zombieTimer then
    self.zombieTimer:stop()
    self.zombieTimer = nil
  end

  -- Stop app watcher
  if self.appWatcher then
    self.appWatcher:stop()
    self.appWatcher = nil
  end

  -- Unregister all apps (stops their watchers)
  for pid, _ in pairs(self.apps) do
    self:unregisterApp(pid)
  end

  -- Cancel pending app timers
  for pid, pending in pairs(self.pendingApps) do
    if pending.timer then pending.timer:stop() end
  end
  self.pendingApps = {}

  -- Cancel pending window timers
  for win, pending in pairs(self.pendingWindows) do
    if pending.timer then pending.timer:stop() end
  end
  self.pendingWindows = {}

  -- Cancel debounce timers
  for id, timer in pairs(self.movedTimers) do
    timer:stop()
  end
  self.movedTimers = {}

  for id, timer in pairs(self.titleTimers) do
    timer:stop()
  end
  self.titleTimers = {}

  self.focusedWindowId = nil
  self.focusedAppPid = nil

  log.i('Tracker stopped')
end

--- Get preFilter config from manager or use default.
--- @return table PreFilter config
function Tracker:_getPreFilterConfig()
  if self.manager and self.manager.preFilter then
    return self.manager.preFilter
  end
  return PreFilter.defaultConfig()
end

--- Safely call a Manager callback, catching errors.
--- @param method string Method name
--- @param ... any Arguments to pass
function Tracker:_notifyManager(method, ...)
  if not self.manager then return end
  local fn = self.manager[method]
  if not fn then return end

  local ok, err = pcall(fn, self.manager, ...)
  if not ok then
    log.ef('Manager.%s error: %s', method, tostring(err))
  end
end

--- Register an app for tracking.
--- @param hsApp userdata The hs.application object
--- @param retryCount number Optional retry count
function Tracker:registerApp(hsApp, retryCount)
  if not self.running then return end
  if not hsApp then return end

  local pid = safeCall(hsApp.pid, hsApp)
  -- Workaround: AXUIElementGetPid() can return -1 for stale AX elements (HSuicore.m doesn't check the return value)
  if not pid or pid <= 0 then return end

  -- Already registered?
  if self.apps[pid] then return end

  -- Cancel any pending retry for this app
  if self.pendingApps[pid] then
    if self.pendingApps[pid].timer then
      self.pendingApps[pid].timer:stop()
    end
    self.pendingApps[pid] = nil
  end

  -- PreFilter check
  local config = self:_getPreFilterConfig()
  local shouldTrack, reason = PreFilter.shouldTrackApp(hsApp, config)
  if not shouldTrack then
    return
  end

  retryCount = (retryCount or 0) + 1

  -- Check if app is ready (can get focused window)
  -- Some apps take time to initialize their accessibility features
  local fw = safeCall(hsApp.focusedWindow, hsApp)

  if fw or retryCount > Config.timing.maxRetries then
    -- Create AppInfo
    local appInfo = AppInfo.new(hsApp, pid)
    if not appInfo then return end

    self.apps[pid] = appInfo

    -- Create watcher for this app's UI events
    -- Note: watcher APIs must be called directly, not through safeCall
    local ok, watcher = pcall(function()
      return hsApp:newWatcher(function(element, event, watcherObj, name)
        self:_onAppUIEvent(element, event, pid, name)
      end)
    end)

    if ok and watcher then
      appInfo.watcher = watcher
      -- Watch for new windows and focus changes
      local startOk = pcall(function()
        watcher:start({
          uiwatcher.windowCreated,
          uiwatcher.focusedWindowChanged,
        })
      end)
      if not startOk then
        log.wf('Failed to start watcher for %s', appInfo.name)
      end
    end

    -- Register existing windows
    self:_registerAppWindows(appInfo)

  else
    -- App not ready, retry later
    local delay = retryCount * Config.timing.retryDelay
    self.pendingApps[pid] = {
      retryCount = retryCount,
      timer = hs.timer.doAfter(delay, function()
        self.pendingApps[pid] = nil
        self:registerApp(hsApp, retryCount)
      end)
    }
  end
end

--- Register all windows for an app.
--- @param appInfo table AppInfo object
function Tracker:_registerAppWindows(appInfo)
  if not appInfo or not appInfo._app then return end

  local windows = safeCall(appInfo._app.allWindows, appInfo._app)
  if not windows then return end

  for _, hsWindow in ipairs(windows) do
    self:registerWindow(hsWindow, appInfo)
  end
end

--- Register a window for tracking.
--- @param hsWindow userdata The hs.window object
--- @param appInfo table The AppInfo for this window's app
--- @param retryCount number Optional retry count
function Tracker:registerWindow(hsWindow, appInfo, retryCount)
  if not self.running then return end
  if not hsWindow or not appInfo then return end

  local id = safeCall(hsWindow.id, hsWindow)

  if not id then
    -- Window doesn't have ID yet, retry later
    retryCount = (retryCount or 0) + 1
    if retryCount <= Config.timing.maxRetries then
      local delay = retryCount * Config.timing.retryDelay
      self.pendingWindows[hsWindow] = {
        retryCount = retryCount,
        appInfo = appInfo,
        timer = hs.timer.doAfter(delay, function()
          self.pendingWindows[hsWindow] = nil
          self:registerWindow(hsWindow, appInfo, retryCount)
        end)
      }
    end
    return
  end

  -- Cancel any pending retry
  if self.pendingWindows[hsWindow] then
    if self.pendingWindows[hsWindow].timer then
      self.pendingWindows[hsWindow].timer:stop()
    end
    self.pendingWindows[hsWindow] = nil
  end

  -- Already registered?
  if appInfo.windows[id] then return end

  -- PreFilter check
  local config = self:_getPreFilterConfig()
  local shouldTrack, reason = PreFilter.shouldTrack(hsWindow, appInfo._app, config)
  if not shouldTrack then
    return
  end

  -- Create WindowInfo
  local windowInfo = WindowInfo.new(hsWindow)
  if not windowInfo then return end

  -- Set app reference
  windowInfo.appName = appInfo.name
  windowInfo.appPid = appInfo.pid

  -- Create watcher for this window's UI events
  -- Note: watcher APIs must be called directly, not through safeCall
  local ok, watcher = pcall(function()
    return hsWindow:newWatcher(function(element, event, watcherObj, name)
      self:_onWindowEvent(event, appInfo.pid, id)
    end)
  end)

  if ok and watcher then
    windowInfo.watcher = watcher
    local startOk = pcall(function()
      watcher:start({
        uiwatcher.elementDestroyed,
        uiwatcher.windowMoved,
        uiwatcher.windowResized,
        uiwatcher.windowMinimized,
        uiwatcher.windowUnminimized,
        uiwatcher.titleChanged,
      })
    end)
    if not startOk then
      log.wf('Failed to start window watcher for %s (%d)', appInfo.name, id)
    end
  end

  -- Store window
  appInfo.windows[id] = windowInfo

  -- Notify manager
  self:_notifyManager('onWindowCreated', windowInfo, appInfo)
end

--- Unregister a window.
--- @param windowInfo table WindowInfo object
--- @param appInfo table AppInfo object
function Tracker:unregisterWindow(windowInfo, appInfo)
  if not windowInfo or not appInfo then return end

  local id = windowInfo.id

  -- Stop window watcher
  if windowInfo.watcher then
    safeCall(windowInfo.watcher.stop, windowInfo.watcher)
    windowInfo.watcher = nil
  end

  -- Cancel debounce timers for this window
  if self.movedTimers[id] then
    self.movedTimers[id]:stop()
    self.movedTimers[id] = nil
  end
  if self.titleTimers[id] then
    self.titleTimers[id]:stop()
    self.titleTimers[id] = nil
  end

  -- Remove from app
  appInfo.windows[id] = nil

  -- Clear focus if this was focused
  if self.focusedWindowId == id then
    self.focusedWindowId = nil
  end

  -- Notify manager
  self:_notifyManager('onWindowDestroyed', windowInfo, appInfo)
end

--- Unregister an app and all its windows.
--- @param pid number Process ID
function Tracker:unregisterApp(pid)
  local appInfo = self.apps[pid]
  if not appInfo then return end

  -- Unregister all windows first
  for id, windowInfo in pairs(appInfo.windows) do
    self:unregisterWindow(windowInfo, appInfo)
  end

  -- Stop app watcher
  if appInfo.watcher then
    safeCall(appInfo.watcher.stop, appInfo.watcher)
    appInfo.watcher = nil
  end

  -- Remove from tracked apps
  self.apps[pid] = nil

  -- Clear focus if this was the focused app
  if self.focusedAppPid == pid then
    self.focusedAppPid = nil
  end
end

--- Handle app watcher events.
--- @param name string App name
--- @param event number Event type
--- @param hsApp userdata hs.application object
function Tracker:_onAppEvent(name, event, hsApp)
  if not self.running then return end
  if not name then return end

  local pid = hsApp and safeCall(hsApp.pid, hsApp)
  -- Workaround: AXUIElementGetPid() can return -1 for stale AX elements (HSuicore.m doesn't check the return value)
  if pid and pid <= 0 then pid = nil end

  if event == appwatcher.launched then
    self:registerApp(hsApp)

  elseif event == appwatcher.terminated then
    if pid then
      -- Cancel any pending retry
      if self.pendingApps[pid] then
        if self.pendingApps[pid].timer then
          self.pendingApps[pid].timer:stop()
        end
        self.pendingApps[pid] = nil
      end
      self:unregisterApp(pid)
    end

  elseif event == appwatcher.activated then
    if pid then
      local appInfo = self.apps[pid]
      if appInfo then
        self.focusedAppPid = pid
        appInfo:refresh()
        self:_notifyManager('onAppActivated', appInfo)

        -- Handle focus change when app is activated (e.g., Command-Tab, mouse click)
        -- The uiwatcher.focusedWindowChanged doesn't fire reliably for these cases
        local focusedWin = safeCall(hsApp.focusedWindow, hsApp)
        if focusedWin then
          local newId = safeCall(focusedWin.id, focusedWin)
          if newId and newId ~= self.focusedWindowId then
            -- Find previous focused window across all apps
            local prevWindowInfo = nil
            if self.focusedWindowId then
              for _, app in pairs(self.apps) do
                for _, info in pairs(app.windows) do
                  if info.id == self.focusedWindowId then
                    prevWindowInfo = info
                    break
                  end
                end
                if prevWindowInfo then break end
              end
            end

            -- Save previous before updating (for deactivated handler)
            self.prevFocusedWindowId = self.focusedWindowId
            self.focusedWindowId = newId

            -- Get or create WindowInfo for the focused window
            local windowInfo = appInfo.windows[newId]
            if not windowInfo then
              self:registerWindow(focusedWin, appInfo)
              windowInfo = appInfo.windows[newId]
            end

            if windowInfo then
              windowInfo.timeFocused = hs.timer.absoluteTime()
              self:_notifyManager('onFocusChanged', windowInfo, appInfo, prevWindowInfo)
            end
          end
        end
      else
        -- App activated but not registered yet, register it
        self:registerApp(hsApp)
      end
    end

  elseif event == appwatcher.deactivated then
    if pid then
      local appInfo = self.apps[pid]
      if appInfo then
        -- Emit unfocused for the previously focused window in this app
        -- This handles Command-Tab, mouse clicks, etc. where the app loses focus
        -- Check both IDs since event order varies: activated may fire before or after deactivated
        local prevWindowInfo = nil
        if self.prevFocusedWindowId then
          prevWindowInfo = appInfo.windows[self.prevFocusedWindowId]
          self.prevFocusedWindowId = nil  -- Clear after use
        end
        if not prevWindowInfo and self.focusedWindowId then
          -- Deactivated fired before activated updated focusedWindowId
          prevWindowInfo = appInfo.windows[self.focusedWindowId]
        end
        if prevWindowInfo then
          self:_notifyManager('onFocusChanged', nil, nil, prevWindowInfo)
        end

        appInfo:refresh()
        self:_notifyManager('onAppDeactivated', appInfo)
      end
    end

  elseif event == appwatcher.hidden then
    if pid then
      local appInfo = self.apps[pid]
      if appInfo then
        appInfo.isHidden = true
        self:_notifyManager('onAppHidden', appInfo)
      end
    end

  elseif event == appwatcher.unhidden then
    if pid then
      local appInfo = self.apps[pid]
      if appInfo then
        appInfo.isHidden = false
        self:_notifyManager('onAppUnhidden', appInfo)
      end
    end
  end
end

--- Handle per-app UI events (windowCreated, focusedWindowChanged).
--- @param element userdata UI element
--- @param event number Event type
--- @param pid number Process ID
--- @param name string App name
function Tracker:_onAppUIEvent(element, event, pid, name)
  if not self.running then return end

  local appInfo = self.apps[pid]
  if not appInfo then return end

  if event == uiwatcher.windowCreated then
    -- element is the new window
    if element then
      self:registerWindow(element, appInfo)
    end

  elseif event == uiwatcher.focusedWindowChanged then
    -- element is the newly focused window
    if element then
      local id = safeCall(element.id, element)
      if id and id ~= self.focusedWindowId then
        local prevWindowInfo = nil
        if self.focusedWindowId then
          -- Find previous focused window across ALL apps (not just current app)
          -- This is important for Command-Tab: the previous window may be in a different app
          for _, app in pairs(self.apps) do
            for _, info in pairs(app.windows) do
              if info.id == self.focusedWindowId then
                prevWindowInfo = info
                break
              end
            end
            if prevWindowInfo then break end
          end
        end

        self.focusedWindowId = id

        -- Get or create WindowInfo for the focused window
        local windowInfo = appInfo.windows[id]
        if not windowInfo then
          -- Window not registered yet, register it
          self:registerWindow(element, appInfo)
          windowInfo = appInfo.windows[id]
        end

        if windowInfo then
          windowInfo.timeFocused = hs.timer.absoluteTime()
          self:_notifyManager('onFocusChanged', windowInfo, appInfo, prevWindowInfo)
        end
      end
    end
  end
end

--- Handle per-window UI events.
--- @param event number Event type
--- @param pid number Process ID
--- @param windowId number Window ID
function Tracker:_onWindowEvent(event, pid, windowId)
  if not self.running then return end

  local appInfo = self.apps[pid]
  if not appInfo then return end

  local windowInfo = appInfo.windows[windowId]
  if not windowInfo then return end

  if event == uiwatcher.elementDestroyed then
    self:unregisterWindow(windowInfo, appInfo)

  elseif event == uiwatcher.windowMoved or event == uiwatcher.windowResized then
    -- Debounce move/resize events
    if self.movedTimers[windowId] then
      self.movedTimers[windowId]:stop()
    end
    self.movedTimers[windowId] = hs.timer.doAfter(Config.timing.movedDebounce, function()
      self.movedTimers[windowId] = nil
      if not self.running then return end
      if not appInfo.windows[windowId] then return end

      -- Refresh and notify
      windowInfo:refresh()
      self:_notifyManager('onWindowMoved', windowInfo, appInfo)
    end)

  elseif event == uiwatcher.windowMinimized then
    windowInfo.isMinimized = true
    windowInfo.isVisible = false
    self:_notifyManager('onWindowMinimized', windowInfo, appInfo)

  elseif event == uiwatcher.windowUnminimized then
    windowInfo.isMinimized = false
    windowInfo:refresh()  -- Get current visibility
    self:_notifyManager('onWindowUnminimized', windowInfo, appInfo)

  elseif event == uiwatcher.titleChanged then
    -- Debounce title change events
    if self.titleTimers[windowId] then
      self.titleTimers[windowId]:stop()
    end
    self.titleTimers[windowId] = hs.timer.doAfter(Config.timing.titleDebounce, function()
      self.titleTimers[windowId] = nil
      if not self.running then return end
      if not appInfo.windows[windowId] then return end

      -- Refresh and notify
      local oldTitle = windowInfo.title
      windowInfo:refresh()
      if windowInfo.title ~= oldTitle then
        self:_notifyManager('onWindowTitleChanged', windowInfo, appInfo)
      end
    end)
  end
end

--- Clean up zombie apps (apps that terminated without notification).
function Tracker:cleanupZombies()
  if not self.running then return end

  -- Snapshot alive pids from NSWorkspace (single call, no per-pid lookup
  -- that would trigger LuaSkin error logs for dead pids).
  local alive = {}
  for _, app in ipairs(hs.application.runningApplications()) do
    local pid = safeCall(app.pid, app)
    if pid then alive[pid] = true end
  end

  for pid, appInfo in pairs(self.apps) do
    if not alive[pid] then
      log.wf('Cleaning up zombie app: %s (%d)', appInfo.name, pid)
      self:unregisterApp(pid)
    end
  end
end

--- Get count of tracked apps.
--- @return number
function Tracker:getAppCount()
  local count = 0
  for _ in pairs(self.apps) do count = count + 1 end
  return count
end

--- Get count of tracked windows.
--- @return number
function Tracker:getWindowCount()
  local count = 0
  for _, appInfo in pairs(self.apps) do
    for _ in pairs(appInfo.windows) do count = count + 1 end
  end
  return count
end

--- String representation for debugging.
function Tracker:__tostring()
  return sformat('Tracker: %d apps, %d windows, running=%s',
    self:getAppCount(), self:getWindowCount(), tostring(self.running))
end

-- Expose for testing
windowfilter._Tracker = Tracker

----------------------------------------------------------------------
-- SECTION 10: MANAGER
----------------------------------------------------------------------
-- Manager is a singleton that coordinates between Tracker and WindowFilter
-- instances. It handles:
-- - Tracker lifecycle (lazy start/stop)
-- - Instance registration (activate/deactivate)
-- - Event routing to active instances
-- - Spaces change handling
-- - Context access (focusedWindowId, activeAppPid)

local Manager = {}
Manager.__index = Manager

-- Singleton instance
local managerInstance = nil

--- Get the Manager singleton instance.
--- Creates it on first call.
--- @return table Manager instance
function Manager.getInstance()
  if not managerInstance then
    managerInstance = Manager._create()
  end
  return managerInstance
end

--- Create a new Manager instance (internal).
--- @return table Manager instance
function Manager._create()
  local self = setmetatable({}, Manager)

  self.tracker = nil              -- Tracker instance (created lazily)
  self.activeInstances = {}       -- {[wf] = true} active windowfilter instances
  self.spacesInstances = {}       -- {[wf] = true} instances that care about spaces
  self.spacesWatcher = nil        -- hs.spaces.watcher
  self.instanceCount = 0          -- Count of active instances
  self.preFilter = PreFilter.defaultConfig()  -- PreFilter config for Tracker

  return self
end

--- Activate a windowfilter instance.
--- Starts Tracker if this is the first active instance.
--- @param wf table WindowFilter instance
function Manager:activate(wf)
  if self.activeInstances[wf] then return end

  self.activeInstances[wf] = true
  self.instanceCount = self.instanceCount + 1

  -- Check if instance cares about spaces
  if wf._trackSpaces then
    self.spacesInstances[wf] = true
  end

  -- Start Tracker if first instance
  if self.instanceCount == 1 then
    self:_start()
  end

  -- Refresh the instance with current windows
  self:_refreshInstance(wf)
end

--- Deactivate a windowfilter instance.
--- Stops Tracker if this was the last active instance.
--- @param wf table WindowFilter instance
function Manager:deactivate(wf)
  if not self.activeInstances[wf] then return end

  self.activeInstances[wf] = nil
  self.spacesInstances[wf] = nil
  self.instanceCount = self.instanceCount - 1

  -- Stop Tracker if last instance
  if self.instanceCount == 0 then
    self:_stop()
  end
end

--- Get context for filter matching.
--- @return table {focusedWindowId, activeAppPid}
function Manager:getContext()
  if self.tracker then
    return {
      focusedWindowId = self.tracker.focusedWindowId,
      activeAppPid = self.tracker.focusedAppPid,
    }
  end
  return {focusedWindowId = nil, activeAppPid = nil}
end

--- Get the Tracker instance (for testing/debugging).
--- @return table|nil Tracker instance or nil if not started
function Manager:getTracker()
  return self.tracker
end

--- Check if Manager is running.
--- @return boolean
function Manager:isRunning()
  return self.tracker ~= nil and self.tracker.running
end

--- Get count of active instances.
--- @return number
function Manager:getInstanceCount()
  return self.instanceCount
end

--- Start the Manager (internal).
--- Creates and starts Tracker, starts spaces watcher.
function Manager:_start()
  if self.tracker then return end

  log.i('Manager starting')

  -- Create and start Tracker
  self.tracker = Tracker.new(self)
  self.tracker:start()

  -- Start spaces watcher
  self:_startSpacesWatcher()
end

--- Stop the Manager (internal).
--- Stops Tracker and spaces watcher.
function Manager:_stop()
  if not self.tracker then return end

  log.i('Manager stopping')

  -- Stop spaces watcher
  self:_stopSpacesWatcher()

  -- Stop and clear Tracker
  self.tracker:stop()
  self.tracker = nil
end

--- Start the spaces watcher (internal).
function Manager:_startSpacesWatcher()
  if self.spacesWatcher then return end

  self.spacesWatcher = hs.spaces.watcher.new(function()
    self:_onSpaceChanged()
  end)
  self.spacesWatcher:start()
end

--- Stop the spaces watcher (internal).
function Manager:_stopSpacesWatcher()
  if not self.spacesWatcher then return end

  self.spacesWatcher:stop()
  self.spacesWatcher = nil
end

--- Handle space change event (internal).
function Manager:_onSpaceChanged()
  -- Delay slightly to let the system settle
  hs.timer.doAfter(Config.timing.spaceChangeDelay, function()
    self:_handleSpaceChange()
  end)
end

--- Process space change after delay (internal).
function Manager:_handleSpaceChange()
  if not self.tracker then return end

  log.i('Space changed, refreshing instances')

  -- Determine which instances to refresh
  local instancesToRefresh = {}

  -- Always refresh space-aware instances
  for wf in pairs(self.spacesInstances) do
    instancesToRefresh[wf] = true
  end

  -- Also refresh all active instances if forceRefreshOnSpaceChange
  if windowfilter.forceRefreshOnSpaceChange then
    for wf in pairs(self.activeInstances) do
      instancesToRefresh[wf] = true
    end
  end

  -- Notify each instance of space change
  for wf in pairs(instancesToRefresh) do
    self:_notifyInstance(wf, 'spaceChanged', nil, nil)
  end
end

--- Refresh a single instance with current windows (internal).
--- Called when instance is activated.
--- @param wf table WindowFilter instance
function Manager:_refreshInstance(wf)
  if not self.tracker then return end

  -- Send windowCreated for all currently tracked windows
  for _, appInfo in pairs(self.tracker.apps) do
    for _, windowInfo in pairs(appInfo.windows) do
      self:_notifyInstance(wf, 'windowCreated', windowInfo, appInfo)
    end
  end
end

--- Notify a single instance of an event (internal).
--- @param wf table WindowFilter instance
--- @param eventType string Event type name
--- @param windowInfo table|nil WindowInfo object
--- @param appInfo table|nil AppInfo object
function Manager:_notifyInstance(wf, eventType, windowInfo, appInfo)
  if not wf._handleTrackerEvent then return end

  local ok, err = pcall(wf._handleTrackerEvent, wf, eventType, windowInfo, appInfo)
  if not ok then
    log.ef('Instance event handler error: %s', tostring(err))
  end
end

--- Route an event to all active instances (internal).
--- @param eventType string Event type name
--- @param windowInfo table|nil WindowInfo object
--- @param appInfo table|nil AppInfo object
function Manager:_routeEvent(eventType, windowInfo, appInfo)
  for wf in pairs(self.activeInstances) do
    self:_notifyInstance(wf, eventType, windowInfo, appInfo)
  end
end

----------------------------------------------------------------------
-- Tracker callback interface implementation
-- These methods are called by Tracker and route to active instances
----------------------------------------------------------------------

-- Generate simple event routing methods.
-- Window events pass (windowInfo, appInfo); app events pass (nil, appInfo).
for _, event in ipairs({
  'windowCreated', 'windowDestroyed', 'windowMoved',
  'windowMinimized', 'windowUnminimized', 'windowTitleChanged',
}) do
  local method = 'on' .. event:sub(1, 1):upper() .. event:sub(2)
  Manager[method] = function(self, windowInfo, appInfo)
    self:_routeEvent(event, windowInfo, appInfo)
  end
end
for _, event in ipairs({
  'appActivated', 'appDeactivated', 'appHidden', 'appUnhidden',
}) do
  local method = 'on' .. event:sub(1, 1):upper() .. event:sub(2)
  Manager[method] = function(self, appInfo)
    self:_routeEvent(event, nil, appInfo)
  end
end

function Manager:onFocusChanged(windowInfo, appInfo, prevWindowInfo)
  -- Route focus change with previous window info
  for wf in pairs(self.activeInstances) do
    if wf._handleFocusChanged then
      local ok, err = pcall(wf._handleFocusChanged, wf, windowInfo, appInfo, prevWindowInfo)
      if not ok then
        log.ef('Instance focus handler error: %s', tostring(err))
      end
    else
      -- Fall back to generic event
      self:_notifyInstance(wf, 'focusChanged', windowInfo, appInfo)
    end
  end
end

--- String representation for debugging.
function Manager:__tostring()
  return sformat('Manager: %d instances, running=%s',
    self.instanceCount, tostring(self:isRunning()))
end

-- Expose for testing
windowfilter._Manager = Manager

--- hs.window.filter.forceRefreshOnSpaceChange
--- Variable
--- Tells all windowfilters whether to refresh all windows when the user switches to a different Mission Control Space.
---
--- Due to OS X limitations Hammerspoon cannot directly query for windows in Spaces other than the current one;
--- therefore when a windowfilter is initially instantiated, it doesn't know about many of these windows.
---
--- If this variable is set to `true`, windowfilters will re-query applications for all their windows whenever a Space change
--- by the user is detected, therefore any existing windows in that Space that were not yet being tracked will become known at that point;
--- if `false` (the default) this won't happen, but the windowfilters will *eventually* learn about these windows
--- anyway, as soon as they're interacted with.
---
--- If you need your windowfilters to become aware of windows across all Spaces as soon as possible, you can set this to `true`,
--- but you'll incur a modest performance penalty on every Space change. If possible, use the `hs.window.filter.switchedToSpace()`
--- callback instead.
---
--- Notes:
---  * If you defined one or more Spaces-aware windowfilters (i.e. when the `currentSpace` field of a filter is present), windows need refreshing at every space change anyway, so this variable is ignored
windowfilter.forceRefreshOnSpaceChange = false

----------------------------------------------------------------------
-- SECTION 11: WINDOWFILTER CLASS (PUBLIC API)
----------------------------------------------------------------------
-- WindowFilter is the main public API. It provides:
-- - Filter configuration (setAppFilter, setDefaultFilter, etc.)
-- - Window queries (isAppAllowed, isWindowAllowed, getWindows)
-- - Event subscriptions (subscribe, unsubscribe)
-- - Lifecycle management (pause, resume, delete, keepActive)

local WindowFilter = {}
WindowFilter.__index = WindowFilter

-- Window state keys for tracking
local STATE_ALLOWED = 'allowed'
local STATE_VISIBLE = 'visible'
local STATE_ON_SCREEN = 'onScreen'
local STATE_IN_SPACE = 'inCurrentSpace'
local STATE_FOCUSED = 'focused'
local STATE_FULLSCREEN = 'fullscreen'
local STATE_TIME_CREATED = 'timeCreated'
local STATE_TIME_FOCUSED = 'timeFocused'

-- Z-order bootstrap: maps window ID -> {timeFocused, timeCreated} for pre-existing windows.
-- Populated once in Tracker:start() from hs.window._orderedwinids(), consumed by
-- WindowFilter:_handleTrackerEvent() when processing initial windowCreated events,
-- then cleared so ongoing events use real timestamps.
local preexistingWindowTimestamps = nil

----------------------------------------------------------------------
-- Constructor
----------------------------------------------------------------------

--- Create a new WindowFilter.
--- @param fn nil|boolean|string|table|function Filter specification
--- @param logname string|nil Optional log name
--- @param loglevel string|nil Optional log level
--- @return table WindowFilter instance
function WindowFilter.new(fn, logname, loglevel)
  local self = setmetatable({}, WindowFilter)

  -- Internal state
  self._filter = Filter.new()           -- Filter instance for rule matching
  self._subscriptions = Subscriptions.new()  -- Event subscriptions
  self._windows = {}                    -- {windowId -> {state table}}
  self._customFilter = nil              -- Custom filter function (if any)
  self._notifyfn = nil                  -- Notify callback for window list changes
  self._paused = false                  -- Paused state
  self._active = false                  -- Whether activated with Manager
  self._trackSpaces = false             -- Whether to track space changes
  self._sortOrder = nil                 -- Sort order for getWindows
  self._currentSpaceOnly = false        -- Only windows in current space
  self._allowedScreens = nil            -- Screen filter
  self._allowedRegions = nil            -- Region filter
  self._allowedWindowCount = 0          -- Count of currently allowed windows

  -- Instance-level logging: use custom logger if logname provided, else module logger
  if logname then
    self.log = logger.new(logname, loglevel or 'warning')
  else
    self.log = log  -- Use module-level logger
  end

  -- Parse constructor argument
  self:_parseConstructorArg(fn)

  return self
end

--- Parse the constructor argument and configure the filter.
--- @param fn nil|boolean|string|table|function
function WindowFilter:_parseConstructorArg(fn)
  if fn == nil then
    -- Default filter: allow all apps except ignoreAlways and ignoreInDefaultFilter
    self._filter:setDefaultFilter(true)
    -- Reject apps in ignoreAlways
    for appname in pairs(ignoreAlways) do
      self._filter:setAppFilter(appname, false)
    end
    -- Reject apps in ignoreInDefaultFilter
    for appname in pairs(ignoreInDefaultFilter) do
      self._filter:setAppFilter(appname, false)
    end
  elseif fn == true then
    -- Allow all apps including ignored ones
    self._filter:setOverrideFilter(true)
  elseif fn == false then
    -- Reject all apps
    self._filter:setDefaultFilter(false)
  elseif type(fn) == 'string' then
    -- Single app name: allow at app level, filter at window level
    self._allowedApps = {[fn] = true}
    self._filter:setDefaultFilter(true)  -- Allow all at app level
    -- Actual filtering happens in isWindowAllowed
  elseif type(fn) == 'function' then
    -- Custom filter function
    self._customFilter = fn
  elseif type(fn) == 'table' then
    -- Could be app list or app rules
    if #fn > 0 then
      -- Array of app names: allow at app level, filter at window level
      self._allowedApps = {}
      for _, appName in ipairs(fn) do
        self._allowedApps[appName] = true
      end
      self._filter:setDefaultFilter(true)  -- Allow all at app level
      -- Actual filtering happens in isWindowAllowed
    else
      -- Table of app rules
      for appName, rules in pairs(fn) do
        self._filter:setAppFilter(appName, rules)
      end
    end
  end
end

----------------------------------------------------------------------
-- Filter Configuration Methods (all return self for chaining)
----------------------------------------------------------------------

--- hs.window.filter:setAppFilter(appname, filter) -> hs.window.filter object
--- Method
--- Sets the detailed filtering rules for the windows of a specific app
---
--- Parameters:
---  * appname - app name as per `hs.application:name()`
---  * filter - if `false`, reject the app; if `true`, `nil`, or omitted, allow all visible windows (in any Space) for the app; otherwise it must be a table describing the filtering rules for the app, via the following fields:
---    * visible - if `true`, only allow visible windows (in any Space); if `false`, reject visible windows; if omitted, this rule is ignored
---    * currentSpace - if `true`, only allow windows in the current Mission Control Space (minimized and hidden windows are included, as they're considered to belong to all Spaces); if `false`, reject windows in the current Space (including all minimized and hidden windows); if omitted, this rule is ignored
---    * fullscreen - if `true`, only allow fullscreen windows; if `false`, reject fullscreen windows; if omitted, this rule is ignored
---    * hasTitlebar - if `true`, only allow windows with titlebar; if `false`, reject window with titlebar; if omitted, this rule is ignored
---    * focused - if `true`, only allow a window while focused; if `false`, reject the focused window; if omitted, this rule is ignored
---    * activeApplication - only allow any of this app's windows while it is (if `true`) or it's not (if `false`) the active application; if omitted, this rule is ignored
---    * allowTitles - if a number, only allow windows whose title is at least as many characters long; if a string or table of strings, only allow windows whose title matches (one of) the pattern(s) as per `string.match`; if omitted, this rule is ignored
---    * rejectTitles - if a string or table of strings, reject windows whose titles matches (one of) the pattern(s) as per `string.match`; if omitted, this rule is ignored
---    * allowRegions - an `hs.geometry` rect or constructor argument, or a list of them, designating (a) screen "region(s)" in absolute coordinates: only allow windows that "cover" at least 50% of (one of) the region(s), and/or windows that have at least 50% of their surface inside (one of) the region(s); if omitted, this rule is ignored
---    * rejectRegions - an `hs.geometry` rect or constructor argument, or a list of them, designating (a) screen "region(s)" in absolute coordinates: reject windows that "cover" at least 50% of (one of) the region(s), and/or windows that have at least 50% of their surface inside (one of) the region(s); if omitted, this rule is ignored
---    * allowScreens - a valid argument for `hs.screen.find()`, or a list of them, indicating one (or more) screen(s): only allow windows that (mostly) lie on (one of) the screen(s); if omitted, this rule is ignored
---    * rejectScreens - a valid argument for `hs.screen.find()`, or a list of them, indicating one (or more) screen(s): reject windows that (mostly) lie on (one of) the screen(s); if omitted, this rule is ignored
---    * allowRoles - if a string or table of strings, only allow these window roles as per `hs.window:subrole()`; if the special string `'*'`, all window roles are allowed; if omitted, use the default allowed roles (defined in `hs.window.filter.allowedWindowRoles`)
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * Passing `focused=true` in `filter` will (naturally) result in the windowfilter ever allowing 1 window at most
---  * If you want to allow *all* windows for an app, including invisible ones, pass an empty table for `filter`
function WindowFilter:setAppFilter(appName, rules)
  self._filter:setAppFilter(appName, rules)
  self:_refreshAllWindows()
  return self
end

--- hs.window.filter:setDefaultFilter(filter) -> hs.window.filter object
--- Method
--- Set the default filtering rules to be used for apps without app-specific rules
---
--- Parameters:
---  * filter - see `hs.window.filter:setAppFilter`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:setDefaultFilter(rules)
  self._filter:setDefaultFilter(rules)
  self:_refreshAllWindows()
  return self
end

--- hs.window.filter:setOverrideFilter(filter) -> hs.window.filter object
--- Method
--- Set overriding filtering rules that will be applied for all apps before any app-specific rules
---
--- Parameters:
---  * filter - see `hs.window.filter:setAppFilter`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:setOverrideFilter(rules)
  self._filter:setOverrideFilter(rules)
  self:_refreshAllWindows()
  return self
end

--- hs.window.filter:setFilters(filters) -> hs.window.filter object
--- Method
--- Sets multiple filtering rules
---
--- Parameters:
---  * filters - table, every element will set an application filter; these elements must:
---    - have a *key* of type string, denoting an application name as per `hs.application:name()`
---    - if the *value* is a boolean, the app will be allowed or rejected accordingly - see `hs.window.filter:allowApp()` and `hs.window.filter:rejectApp()`
---    - if the *value* is a table, it must contain the accept/reject rules for the app *as key/value pairs*; valid keys and values are described in `hs.window.filter:setAppFilter()`
---    - the key can be one of the special strings `"default"` and `"override"`, which will set the default and override filter respectively
---    - the key can be the special string `"sortOrder"`; the value must be one of the `sortBy...` constants as per `hs.window.filter:setSortOrder()`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * every filter definition in `filters` will overwrite the preexisting one for the relevant application, if present; this also applies to the special default and override filters, if included
function WindowFilter:setFilters(filters)
  if not filters then return self end

  -- Handle sortOrder if present
  if filters.sortOrder then
    self._sortOrder = filters.sortOrder
  end

  -- Apply filters
  for appName, rules in pairs(filters) do
    if appName ~= 'sortOrder' then
      if appName == 'default' then
        self:setDefaultFilter(rules)
      elseif appName == 'override' then
        self:setOverrideFilter(rules)
      else
        self:setAppFilter(appName, rules)
      end
    end
  end

  return self
end

--- hs.window.filter:getFilters() -> table
--- Method
--- Return a table with all the filtering rules defined for this windowfilter
---
--- Parameters:
---  * None
---
--- Returns:
---  * a table containing the filtering rules of this windowfilter; you can pass this table (optionally after performing valid manipulations) to `hs.window.filter:setFilters()` and `hs.window.filter.new()`
function WindowFilter:getFilters()
  return self._filter:getFilters()
end

--- hs.window.filter:allowApp(appname) -> hs.window.filter object
--- Method
--- Sets the windowfilter to allow all visible windows belonging to a specific app
---
--- Parameters:
---  * appname - app name as per `hs.application:name()`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * this is just a convenience wrapper for `windowfilter:setAppFilter(appname,{visible=true})`
function WindowFilter:allowApp(appName)
  return self:setAppFilter(appName, true)
end

--- hs.window.filter:rejectApp(appname) -> hs.window.filter object
--- Method
--- Sets the windowfilter to outright reject any windows belonging to a specific app
---
--- Parameters:
---  * appname - app name as per `hs.application:name()`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * this is just a convenience wrapper for `windowfilter:setAppFilter(appname,false)`
function WindowFilter:rejectApp(appName)
  return self:setAppFilter(appName, false)
end

----------------------------------------------------------------------
-- Query Methods
----------------------------------------------------------------------

--- hs.window.filter:isAppAllowed(appname) -> boolean
--- Method
--- Checks if an app is allowed by the windowfilter
---
--- Parameters:
---  * appname - app name as per `hs.application:name()`
---
--- Returns:
---  * `false` if the app is rejected by the windowfilter; `true` otherwise
function WindowFilter:isAppAllowed(appName)
  -- Custom filter functions allow all apps (filtering at window level)
  if self._customFilter then
    return true
  end
  return self._filter:isAppAllowed(appName)
end

--- hs.window.filter:isWindowAllowed(window) -> boolean
--- Method
--- Checks if a window is allowed by the windowfilter
---
--- Parameters:
---  * window - an `hs.window` object to check
---
--- Returns:
---  * `true` if the window is allowed by the windowfilter, `false` otherwise; `nil` if an invalid object was passed
function WindowFilter:isWindowAllowed(hsWindow)
  if not hsWindow then return false end

  -- Custom filter function bypasses Filter logic
  if self._customFilter then
    local ok, result = pcall(self._customFilter, hsWindow)
    return ok and result == true
  end

  -- Build WindowInfo and check against filter
  local windowInfo = WindowInfo.new(hsWindow)
  if not windowInfo.id then return false end

  local appInfo = nil
  local hsApp = safeCall(hsWindow.application, hsWindow)
  if hsApp then
    appInfo = AppInfo.new(hsApp)
  end

  -- Check app list filter (from string/array constructor)
  if self._allowedApps then
    local appName = appInfo and appInfo.name
    if not appName or not self._allowedApps[appName] then
      return false
    end
  end

  local context = Manager.getInstance():getContext()
  return self._filter:matchWindow(windowInfo, appInfo, context)
end

----------------------------------------------------------------------
-- Configuration Methods
----------------------------------------------------------------------

--- hs.window.filter:setSortOrder(sortOrder) -> hs.window.filter object
--- Method
--- Sets the sort order for this windowfilter's `:getWindows()` method
---
--- Parameters:
---  * sortOrder - one of the `hs.window.filter.sortBy...` constants
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * The default sort order is `hs.window.filter.sortByFocusedLast`
function WindowFilter:setSortOrder(order)
  self._sortOrder = order
  return self
end

-- Sorting comparators for getWindows
local sortingComparators = {
  focusedLast = function(a, b)
    return (a[STATE_TIME_FOCUSED] or 0) > (b[STATE_TIME_FOCUSED] or 0)
  end,
  focused = function(a, b)
    return (a[STATE_TIME_FOCUSED] or 0) < (b[STATE_TIME_FOCUSED] or 0)
  end,
  createdLast = function(a, b)
    return (a[STATE_TIME_CREATED] or 0) > (b[STATE_TIME_CREATED] or 0)
  end,
  created = function(a, b)
    return (a[STATE_TIME_CREATED] or 0) < (b[STATE_TIME_CREATED] or 0)
  end,
}

--- hs.window.filter:getWindows([sortOrder]) -> list of hs.window objects
--- Method
--- Gets the current windows allowed by this windowfilter
---
--- Parameters:
---  * sortOrder - (optional) one of the `hs.window.filter.sortBy...` constants to override the windowfilter's sort order (this does not change the internal sort order)
---
--- Returns:
---  * a list of `hs.window` objects
function WindowFilter:getWindows(sortOrder)
  -- One-shot activation: temporarily activate if not active
  local wasActive = self._active
  if not wasActive then
    Manager.getInstance():activate(self)
    self._active = true
  end

  -- Collect allowed windows with their state for sorting
  local windowsWithState = {}
  local manager = Manager.getInstance()
  local tracker = manager:getTracker()
  local foundStale = false

  for windowId, state in pairs(self._windows) do
    if state[STATE_ALLOWED] then
      -- Get the hs.window object from tracker
      local hsWindow = nil
      if tracker then
        for _, appInfo in pairs(tracker.apps) do
          if appInfo.windows[windowId] then
            hsWindow = appInfo.windows[windowId]._window
            break
          end
        end
      end
      -- Validate window is still valid (app hasn't terminated)
      -- Check both id() and application() since orphaned windows may still have an id
      if hsWindow and safeCall(hsWindow.id, hsWindow) and safeCall(hsWindow.application, hsWindow) then
        windowsWithState[#windowsWithState + 1] = {
          window = hsWindow,
          state = state,
          [STATE_TIME_FOCUSED] = state[STATE_TIME_FOCUSED],
          [STATE_TIME_CREATED] = state[STATE_TIME_CREATED],
        }
      else
        foundStale = true
      end
    end
  end

  -- If stale windows were found, wake up the zombie cleanup
  if foundStale and tracker and tracker.cleanupZombies then
    timer.doAfter(0, function() tracker:cleanupZombies() end)
  end

  -- Sort windows
  local order = sortOrder or self._sortOrder or 'focusedLast'
  local comparator = sortingComparators[order]
  if comparator then
    tsort(windowsWithState, comparator)
  end

  -- Extract just the hs.window objects
  local result = {}
  for i, entry in ipairs(windowsWithState) do
    result[i] = entry.window
  end

  -- Pause if wasn't active before (one-shot mode)
  if not wasActive then
    self:pause()
  end

  return result
end

--- hs.window.filter:setCurrentSpace(val) -> hs.window.filter object
--- Method
--- Sets whether the windowfilter should only allow (or reject) windows in the current Mission Control Space
---
--- Parameters:
---  * val - boolean; if `true`, only allow windows in the current Mission Control Space, plus minimized and hidden windows; if `false`, reject them; if `nil`, ignore Mission Control Spaces
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * This is just a convenience wrapper for setting the `currentSpace` field in the `override` filter
---  * Spaces-aware windowfilters might experience a (sometimes significant) delay after every Space switch
function WindowFilter:setCurrentSpace(current)
  self._currentSpaceOnly = current
  if current then
    self._trackSpaces = true
    -- Update Manager registration if active
    if self._active then
      Manager.getInstance().spacesInstances[self] = true
    end
  end
  self:_refreshAllWindows()
  return self
end

--- hs.window.filter:setScreens(screens) -> hs.window.filter object
--- Method
--- Sets the allowed screens for this windowfilter
---
--- Parameters:
---  * screens - a valid argument for `hs.screen.find()`, or a list of them, indicating the allowed screen(s) for this windowfilter
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * This is just a convenience wrapper for setting the `allowScreens` field in the `override` filter
function WindowFilter:_setOverrideField(field, value)
  local override = self._filter._rules.override
  if override ~= false then
    override = override or {}
    override[field] = value
    self._filter:setOverrideFilter(override)
  end
  self:_refreshAllWindows()
  return self
end

function WindowFilter:setScreens(screens)
  self._allowedScreens = screens
  return self:_setOverrideField('allowScreens', screens)
end

--- hs.window.filter:setRegions(regions) -> hs.window.filter object
--- Method
--- Sets the allowed screen regions for this windowfilter
---
--- Parameters:
---  * regions - an `hs.geometry` rect or constructor argument, or a list of them, indicating the allowed region(s) for this windowfilter
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * This is just a convenience wrapper for setting the `allowRegions` field in the `override` filter
function WindowFilter:setRegions(regions)
  self._allowedRegions = regions
  return self:_setOverrideField('allowRegions', regions)
end

----------------------------------------------------------------------
-- Lifecycle Methods
----------------------------------------------------------------------

--- hs.window.filter:pause() -> hs.window.filter object
--- Method
--- Stops the windowfilter event subscriptions; no more event callbacks will be triggered, but the subscriptions remain intact for a subsequent call to `hs.window.filter:resume()`
---
--- Parameters:
---  * None
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:pause()
  self._paused = true
  return self
end

--- hs.window.filter:resume() -> hs.window.filter object
--- Method
--- Resumes the windowfilter event subscriptions
---
--- Parameters:
---  * None
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:resume()
  self._paused = false
  return self
end

--- hs.window.filter:delete()
--- Method
--- Deletes the windowfilter, deactivating it and releasing resources
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function WindowFilter:delete()
  if self._active then
    Manager.getInstance():deactivate(self)
    self._active = false
  end
  self._subscriptions:removeAll()
  self._windows = {}
  return nil
end

--- hs.window.filter:keepActive([active]) -> hs.window.filter object
--- Method
--- Keeps the windowfilter active even when there are no subscriptions
---
--- Parameters:
---  * active - (optional) if `false`, stop keeping active; defaults to `true`
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * This is useful for windowfilters that are only used via `:getWindows()` without subscriptions
function WindowFilter:keepActive(keep)
  if keep == nil then keep = true end
  if keep and not self._active then
    Manager.getInstance():activate(self)
    self._active = true
  end
  return self
end

--- hs.window.filter:copy() -> hs.window.filter object
--- Method
--- Returns a copy of this windowfilter that can be further restricted or expanded
---
--- Parameters:
---  * None
---
--- Returns:
---  * a new `hs.window.filter` object
function WindowFilter:copy()
  local new = WindowFilter.new()
  new._filter = self._filter:copy()
  new._customFilter = self._customFilter
  new._sortOrder = self._sortOrder
  new._currentSpaceOnly = self._currentSpaceOnly
  new._trackSpaces = self._trackSpaces
  new._allowedScreens = self._allowedScreens
  new._allowedRegions = self._allowedRegions
  return new
end

----------------------------------------------------------------------
-- Subscription Methods
----------------------------------------------------------------------

--- hs.window.filter:subscribe(event, fn[, immediate]) -> hs.window.filter object
--- Method
--- Subscribe to one or more events on the allowed windows
---
--- Parameters:
---  * event - string or list of strings, the event(s) to subscribe to (see the `hs.window.filter` constants); alternatively, this can be a map `{event1=fn1,event2=fn2,...}`: fnN will be subscribed to eventN
---  * fn - function or list of functions, the callback(s) to add for the event(s); each will be passed 3 parameters:
---    * a `hs.window` object referring to the event's window
---    * a string containing the application name (`window:application():name()`) for convenience
---    * a string containing the event that caused the callback
---  * immediate - (optional) if `true`, also call all the callbacks immediately for windows that satisfy the event(s) criteria
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
---
--- Notes:
---  * If the windowfilter was paused with `hs.window.filter:pause()`, calling this will resume it.
function WindowFilter:subscribe(event, fn)
  -- Handle different calling conventions
  if type(event) == 'function' then
    -- subscribe(fn) - subscribe to all events
    fn = event
    for eventName in pairs(windowfilter) do
      if type(windowfilter[eventName]) == 'number' then
        -- Skip non-event constants
      elseif type(eventName) == 'string' and eventName:match('^window') then
        self._subscriptions:add(eventName, fn)
      end
    end
  elseif type(event) == 'table' then
    local k = next(event)
    if type(k) == 'number' then
      -- subscribe({event1, event2, ...}, fn) - list of event names with shared callback
      if not fn then error('missing parameter fn', 2) end
      for _, eventName in ipairs(event) do
        self._subscriptions:add(eventName, fn)
      end
    else
      -- subscribe({event = fn, ...}) - map of event name to callback
      for eventName, callback in pairs(event) do
        self._subscriptions:add(eventName, callback)
      end
    end
  else
    -- subscribe(event, fn)
    self._subscriptions:add(event, fn)
  end

  -- Activate with Manager if not already active
  if not self._active and self._subscriptions:hasAny() then
    Manager.getInstance():activate(self)
    self._active = true
  end

  -- Resume if paused (as documented)
  if self._paused and self._subscriptions:hasAny() then
    self:resume()
  end

  return self
end

--- hs.window.filter:unsubscribe([event][, fn]) -> hs.window.filter object
--- Method
--- Removes one or more event subscriptions
---
--- Parameters:
---  * event - string or list of strings, the event(s) to unsubscribe; if omitted, `fn`(s) will be unsubscribed from all events; alternatively, this can be a map `{event1=fn1,event2=fn2,...}`
---  * fn - function or list of functions, the callback(s) to remove; if omitted, all callbacks will be unsubscribed from `event`(s)
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:unsubscribe(event, fn)
  if event == nil then
    -- unsubscribe() - remove all
    self._subscriptions:removeAll()
  elseif type(event) == 'function' then
    -- unsubscribe(fn) - remove this callback from all events
    self._subscriptions:removeAll(event)
  elseif type(event) == 'table' then
    -- unsubscribe({event, ...}) - remove all callbacks for these events
    for _, eventName in ipairs(event) do
      self._subscriptions:removeAll(eventName)
    end
  else
    -- unsubscribe(event, fn)
    if fn then
      self._subscriptions:remove(event, fn)
    else
      self._subscriptions:removeAll(event)
    end
  end

  return self
end

--- hs.window.filter:unsubscribeAll() -> hs.window.filter object
--- Method
--- Removes all event subscriptions
---
--- Parameters:
---  * None
---
--- Returns:
---  * the `hs.window.filter` object for method chaining
function WindowFilter:unsubscribeAll()
  self._subscriptions:removeAll()
  return self
end

--- Set a callback to be notified when the window list changes.
--- @param fn function|nil Callback function (receives list of windows and event)
--- @param fnEmpty function|nil Optional callback for when filter has no windows
--- @param immediate boolean|nil If true, also call callback immediately
--- @return table self
function WindowFilter:notify(fn, fnEmpty, immediate)
  if fn ~= nil and type(fn) ~= 'function' then
    error('fn must be a function or nil', 2)
  end
  -- Handle optional fnEmpty and immediate arguments
  if fnEmpty and type(fnEmpty) ~= 'function' then
    fnEmpty = nil
    immediate = true
  end
  if fnEmpty ~= nil and type(fnEmpty) ~= 'function' then
    error('fnEmpty must be a function or nil', 2)
  end

  -- Store the notify function
  if fnEmpty then
    self._notifyfn = function(wins, event)
      if #wins > 0 then
        return fn(wins, event)
      else
        return fnEmpty()
      end
    end
  else
    self._notifyfn = fn
  end

  -- Activate or deactivate based on whether we have a notify function
  if fn then
    if not self._active then
      Manager.getInstance():activate(self)
      self._active = true
    end
  elseif not self._subscriptions:hasAny() then
    self:pause()
  end

  -- Call immediately if requested
  if fn and immediate then
    self._notifyfn(self:getWindows(), nil)
  end

  return self
end

----------------------------------------------------------------------
-- Event Handling (called by Manager)
----------------------------------------------------------------------

--- Handle an event from the Tracker via Manager.
--- @param eventType string Event type name
--- @param windowInfo table|nil WindowInfo object
--- @param appInfo table|nil AppInfo object
function WindowFilter:_handleTrackerEvent(eventType, windowInfo, appInfo)
  if self._paused then return end

  -- Handle app-level events
  if eventType == 'appActivated' or eventType == 'appDeactivated' or
     eventType == 'appHidden' or eventType == 'appUnhidden' then
    self:_handleAppEvent(eventType, appInfo)
    return
  end

  -- Handle space change
  if eventType == 'spaceChanged' then
    self:_handleSpaceChange()
    return
  end

  -- Window events require windowInfo
  if not windowInfo or not windowInfo.id then return end

  -- Get or create window state
  local windowId = windowInfo.id
  local oldState = self._windows[windowId]
  local newState = self:_computeWindowState(windowInfo, appInfo)
  local now = timer.secondsSinceEpoch()

  -- Handle window destruction
  if eventType == 'windowDestroyed' then
    if oldState and oldState[STATE_ALLOWED] then
      self:_emitEvent('windowDestroyed', windowInfo, appInfo)
      self:_emitStateChanges(oldState, {}, windowInfo, appInfo)
    end
    self._windows[windowId] = nil
    return
  end

  -- Track timestamps for sorting
  if oldState then
    -- Preserve existing timestamps
    newState[STATE_TIME_CREATED] = oldState[STATE_TIME_CREATED]
    newState[STATE_TIME_FOCUSED] = oldState[STATE_TIME_FOCUSED]
  end
  -- Set timeCreated if window first becomes allowed
  if newState[STATE_ALLOWED] and not newState[STATE_TIME_CREATED] then
    -- Use z-order bootstrap timestamps for pre-existing windows
    local zts = preexistingWindowTimestamps and preexistingWindowTimestamps[windowId]
    if zts then
      newState[STATE_TIME_CREATED] = zts.timeCreated
      newState[STATE_TIME_FOCUSED] = zts.timeFocused
    else
      newState[STATE_TIME_CREATED] = now
    end
  end
  -- Update timeFocused on focus events
  if eventType == 'windowFocused' and newState[STATE_ALLOWED] then
    newState[STATE_TIME_FOCUSED] = now
  end

  -- Store new state
  self._windows[windowId] = newState

  -- Emit the raw event if window is allowed
  if newState[STATE_ALLOWED] then
    self:_emitEvent(eventType, windowInfo, appInfo)
  end

  -- Emit state change events
  self:_emitStateChanges(oldState or {}, newState, windowInfo, appInfo)
end

--- Handle focus change event (called by Manager with extra context).
--- @param windowInfo table|nil WindowInfo for newly focused window
--- @param appInfo table|nil AppInfo for newly focused app
--- @param prevWindowInfo table|nil WindowInfo for previously focused window
function WindowFilter:_handleFocusChanged(windowInfo, appInfo, prevWindowInfo)
  if self._paused then return end

  -- Handle unfocus of previous window
  if prevWindowInfo and prevWindowInfo.id then
    local oldState = self._windows[prevWindowInfo.id]
    if oldState and oldState[STATE_ALLOWED] then
      oldState[STATE_FOCUSED] = false
      self:_emitEvent('windowUnfocused', prevWindowInfo, nil)
    end
  end

  -- Handle focus of new window
  if windowInfo and windowInfo.id then
    local newState = self._windows[windowInfo.id]
    if newState and newState[STATE_ALLOWED] then
      newState[STATE_FOCUSED] = true
      newState[STATE_TIME_FOCUSED] = timer.secondsSinceEpoch()
      self:_emitEvent('windowFocused', windowInfo, appInfo)
    end
  end
end

--- Compute the current state of a window.
--- @param windowInfo table WindowInfo object
--- @param appInfo table|nil AppInfo object
--- @return table State table
function WindowFilter:_computeWindowState(windowInfo, appInfo)
  local state = {}
  local context = Manager.getInstance():getContext()

  -- Check app list filter (from string/array constructor)
  if self._allowedApps then
    local appName = windowInfo.appName or (appInfo and appInfo.name) or ''
    if not self._allowedApps[appName] then
      state[STATE_ALLOWED] = false
      return state
    end
  end

  -- Check if window passes filter
  if self._customFilter then
    -- For custom filters, we need the actual window object
    -- windowInfo._window may be stale, so we check what we can
    state[STATE_ALLOWED] = true  -- Assume allowed, will be refined
  else
    state[STATE_ALLOWED] = self._filter:matchWindow(windowInfo, appInfo, context)
  end

  -- Check visibility (not hidden by app hide)
  state[STATE_VISIBLE] = not windowInfo.isHidden

  -- Check on screen (not minimized, has valid frame)
  state[STATE_ON_SCREEN] = not windowInfo.isMinimized and windowInfo.frame ~= nil

  -- Check current space (if tracking)
  if self._currentSpaceOnly then
    -- For now, assume in current space if visible
    -- Full implementation would check hs.spaces
    state[STATE_IN_SPACE] = state[STATE_VISIBLE]
  else
    state[STATE_IN_SPACE] = true
  end

  -- Check focused
  state[STATE_FOCUSED] = (context.focusedWindowId == windowInfo.id)

  -- Check fullscreen
  state[STATE_FULLSCREEN] = windowInfo.isFullscreen or false

  return state
end

--- Emit state change events based on old vs new state.
--- @param oldState table Previous state
--- @param newState table New state
--- @param windowInfo table WindowInfo object
--- @param appInfo table|nil AppInfo object
function WindowFilter:_emitStateChanges(oldState, newState, windowInfo, appInfo)
  local wasAllowed = oldState[STATE_ALLOWED]
  local isAllowed = newState[STATE_ALLOWED]

  -- windowAllowed / windowRejected and count tracking
  if isAllowed and not wasAllowed then
    self._allowedWindowCount = self._allowedWindowCount + 1
    self:_emitEvent('windowAllowed', windowInfo, appInfo)
    -- hasWindow: fires when count goes from 0 to 1
    if self._allowedWindowCount == 1 then
      self:_emitEvent('hasWindow', windowInfo, appInfo)
    end
  elseif not isAllowed and wasAllowed then
    self._allowedWindowCount = self._allowedWindowCount - 1
    self:_emitEvent('windowRejected', windowInfo, appInfo)
    -- hasNoWindows: fires when count goes from 1 to 0
    if self._allowedWindowCount == 0 then
      self:_emitEvent('hasNoWindows', windowInfo, appInfo)
    end
  end

  -- Only emit other state changes if window is/was allowed
  if not isAllowed and not wasAllowed then return end

  -- Emit boolean state transition events
  local stateTransitions = {
    {STATE_VISIBLE,    'windowVisible',        'windowNotVisible'},
    {STATE_ON_SCREEN,  'windowOnScreen',        'windowNotOnScreen'},
    {STATE_IN_SPACE,   'windowInCurrentSpace',  'windowNotInCurrentSpace'},
    {STATE_FULLSCREEN, 'windowFullscreened',     'windowUnfullscreened'},
  }
  for _, t in ipairs(stateTransitions) do
    local was, is = oldState[t[1]], newState[t[1]]
    if isAllowed and is and not was then
      self:_emitEvent(t[2], windowInfo, appInfo)
    elseif wasAllowed and not is and was then
      self:_emitEvent(t[3], windowInfo, appInfo)
    end
  end

  -- windowMinimized / windowUnminimized (derived from onScreen, custom logic)
  local wasOnScreen, isOnScreen = oldState[STATE_ON_SCREEN], newState[STATE_ON_SCREEN]
  if isAllowed and not isOnScreen and wasOnScreen and not newState[STATE_VISIBLE] == oldState[STATE_VISIBLE] then
    if windowInfo.isMinimized then
      self:_emitEvent('windowMinimized', windowInfo, appInfo)
    end
  elseif isAllowed and isOnScreen and not wasOnScreen then
    if not windowInfo.isMinimized and oldState[STATE_ON_SCREEN] == false then
      self:_emitEvent('windowUnminimized', windowInfo, appInfo)
    end
  end

  -- windowsChanged pseudo-event: fires whenever the allowed set changes
  if isAllowed ~= wasAllowed then
    -- Pass a random allowed window (or nil if none)
    local anyWindow, anyApp = nil, nil
    for _, state in pairs(self._windows) do
      if state[STATE_ALLOWED] then
        anyWindow = windowInfo
        anyApp = appInfo
        break
      end
    end
    self:_emitEvent('windowsChanged', anyWindow or windowInfo, appInfo)

    -- Call notify function if window list changed
    if self._notifyfn then
      local eventType = isAllowed and 'windowAllowed' or 'windowRejected'
      self._notifyfn(self:getWindows(), eventType)
    end
  end
end

--- Handle app-level events.
--- @param eventType string Event type
--- @param appInfo table AppInfo object
function WindowFilter:_handleAppEvent(eventType, appInfo)
  if not appInfo then return end

  -- Find windows belonging to this app and update their state
  for windowId, state in pairs(self._windows) do
    -- We'd need to check if window belongs to app
    -- For now, emit the app event if we have any allowed windows from this app
    if state[STATE_ALLOWED] then
      -- Emit hidden/shown events for windows
      if eventType == 'appHidden' then
        self:_emitEvent('windowHidden', {id = windowId}, appInfo)
      elseif eventType == 'appUnhidden' then
        self:_emitEvent('windowUnhidden', {id = windowId}, appInfo)
      end
    end
  end
end

--- Handle space change.
function WindowFilter:_handleSpaceChange()
  -- Refresh all windows to update inCurrentSpace state
  self:_refreshAllWindows()
end

--- Refresh state for all tracked windows.
function WindowFilter:_refreshAllWindows()
  -- This will be called when filter configuration changes
  -- Re-evaluate all windows and emit appropriate events
  local manager = Manager.getInstance()
  if not manager:isRunning() then return end

  local tracker = manager:getTracker()
  if not tracker then return end

  local now = timer.secondsSinceEpoch()
  local context = manager:getContext()

  -- Re-process all tracked windows
  for _, appInfo in pairs(tracker.apps) do
    for _, windowInfo in pairs(appInfo.windows) do
      local oldState = self._windows[windowInfo.id] or {}
      local newState = self:_computeWindowState(windowInfo, appInfo)

      -- Preserve or set timestamps
      if oldState[STATE_TIME_CREATED] then
        newState[STATE_TIME_CREATED] = oldState[STATE_TIME_CREATED]
        newState[STATE_TIME_FOCUSED] = oldState[STATE_TIME_FOCUSED]
      elseif newState[STATE_ALLOWED] then
        local zts = preexistingWindowTimestamps
          and preexistingWindowTimestamps[windowInfo.id]
        if zts then
          newState[STATE_TIME_CREATED] = zts.timeCreated
          newState[STATE_TIME_FOCUSED] = zts.timeFocused
        else
          newState[STATE_TIME_CREATED] = now
          -- Set timeFocused if this is the focused window
          if context.focusedWindowId == windowInfo.id then
            newState[STATE_TIME_FOCUSED] = now
          end
        end
      end

      self._windows[windowInfo.id] = newState
      self:_emitStateChanges(oldState, newState, windowInfo, appInfo)
    end
  end
end

--- Emit an event to subscribers.
--- @param eventType string Event type
--- @param windowInfo table WindowInfo object
--- @param appInfo table|nil AppInfo object
function WindowFilter:_emitEvent(eventType, windowInfo, appInfo)
  -- Get the hs.window object if available
  local hsWindow = windowInfo and windowInfo._window or nil
  local appName = appInfo and appInfo.name or (windowInfo and windowInfo.appName) or nil

  self._subscriptions:emit(eventType, hsWindow, appName, eventType)
end

----------------------------------------------------------------------
-- String representation
----------------------------------------------------------------------

function WindowFilter:__tostring()
  local count = 0
  for _ in pairs(self._windows) do count = count + 1 end
  return sformat('WindowFilter: %d windows, active=%s, paused=%s',
    count, tostring(self._active), tostring(self._paused))
end

----------------------------------------------------------------------
-- Module-level new function
----------------------------------------------------------------------

--- hs.window.filter.new(fn[, logname[, loglevel]]) -> hs.window.filter object
--- Constructor
--- Creates a new hs.window.filter instance
---
--- Parameters:
---  * fn
---    * if `nil`, returns a copy of the default windowfilter, including any customizations you might have applied to it so far; you can then further restrict or expand it
---    * if `true`, returns an empty windowfilter that allows every window
---    * if `false`, returns a windowfilter with a default rule to reject every window
---    * if a string or table of strings, returns a windowfilter that only allows visible windows of the specified apps as per `hs.application:name()`
---    * if a table, you can fully define a windowfilter without having to call any methods after construction; the table must be structured as per `hs.window.filter:setFilters()`; if not specified in the table, the default filter in the new windowfilter will reject all windows
---    * otherwise it must be a function that accepts an `hs.window` object and returns `true` if the window is allowed or `false` otherwise; this way you can define a fully custom windowfilter
---  * logname - (optional) name of the `hs.logger` instance for the new windowfilter; if omitted, the class logger will be used
---  * loglevel - (optional) log level for the `hs.logger` instance for the new windowfilter
---
--- Returns:
---  * a new windowfilter instance
function windowfilter.new(fn, logname, loglevel)
  return WindowFilter.new(fn, logname, loglevel)
end

-- Expose for testing
windowfilter._WindowFilter = WindowFilter

----------------------------------------------------------------------
-- SECTION 12: MODULE VARIABLES AND SINGLETONS
----------------------------------------------------------------------

--- hs.window.filter.allowedWindowRoles
--- Variable
--- A table of window roles allowed by default.
--- Set roles as keys: `{AXStandardWindow=true, AXDialog=true}`
windowfilter.allowedWindowRoles = {
  AXStandardWindow = true,
  AXDialog = true,
  AXSystemDialog = true,
}

--- hs.window.filter.ignoreInDefaultFilter
--- Variable
--- Apps to reject in the default filter (but not in new(true)).
--- These are apps with transient windows unlikely to be useful.
windowfilter.ignoreInDefaultFilter = {}
do
  local SKIP_APPS_TRANSIENT_WINDOWS = {
    'Spotlight', 'Notification Center', 'loginwindow', 'ScreenSaverEngine',
    'PressAndHold', 'PopClip', 'Pastebot', 'Fantastical', 'Keychain Access',
    'SecurityAgent', 'Reeder', 'ScreenFloat - Screenshot Tools', 'Dropzone',
    'Alfred', 'Alfred 2', 'Alfred 3', 'Alfred Preferences', 'Keka',
    'Pastebot', 'Bartender', 'Bartender 2', 'Bartender 3',
    'Focus', 'Timing', 'Timing 2', 'Flux', 'Flycut',
  }
  for _, appname in ipairs(SKIP_APPS_TRANSIENT_WINDOWS) do
    windowfilter.ignoreInDefaultFilter[appname] = true
  end
end

--- hs.window.filter.default
--- Constant
--- The default windowfilter; it filters apps whose windows are transient in nature so that you're unlikely to ever need or want to manage them
--- It also filters non-standard windows like popup menus, floating toolbars, etc.
---
--- Notes:
---  * While you can customize the default windowfilter, it's usually advisable to make your customizations on a copy of it (see `hs.window.filter.new(nil)`)

--- hs.window.filter.defaultCurrentSpace
--- Constant
--- A copy of the default windowfilter that only allows windows in the current Mission Control Space
---
--- Notes:
---  * This windowfilter will also filter windows belonging to other Spaces. This can be useful to prevent the system from switching to other Spaces when performing window management operations

-- Singletons for default and defaultCurrentSpace
local defaultwf = nil
local defaultCurrentSpacewf = nil

-- Create the default windowfilter singleton
local function makeDefault()
  if not defaultwf then
    defaultwf = windowfilter.new(true, 'wf-default')
    -- Reject apps in ignoreInDefaultFilter
    for appname in pairs(windowfilter.ignoreInDefaultFilter) do
      defaultwf:rejectApp(appname)
    end
    -- Special handling for Hammerspoon
    defaultwf:setAppFilter('Hammerspoon', {
      allowTitles = {'Preferences', 'Console'},
      allowRoles = 'AXStandardWindow'
    })
    -- Default to visible windows only
    defaultwf:setDefaultFilter({visible = true})
    -- Keep Manager running for performance (like original implementation)
    defaultwf:keepActive()
  end
  return defaultwf
end

-- Create the defaultCurrentSpace windowfilter singleton
local function makeDefaultCurrentSpace()
  if not defaultCurrentSpacewf then
    defaultCurrentSpacewf = makeDefault():copy()
    defaultCurrentSpacewf:setCurrentSpace(true)
  end
  return defaultCurrentSpacewf
end

----------------------------------------------------------------------
-- SECTION 13: MODULE FUNCTIONS
----------------------------------------------------------------------

--- hs.window.filter.copy(wf) -> hs.window.filter object
--- Function
--- Creates a copy of a windowfilter.
--- @param wf table WindowFilter to copy
--- @param logname string|nil Optional log name
--- @param loglevel string|nil Optional log level
--- @return table New WindowFilter copy
function windowfilter.copy(wf, logname, loglevel)
  if not wf or not wf.copy then
    error('wf must be a windowfilter object', 2)
  end
  local new = wf:copy()
  if logname then new._logname = logname end
  if loglevel then new._loglevel = loglevel end
  return new
end

--- hs.window.filter.iswf(t) -> boolean
--- Function
--- Checks if a value is a windowfilter object.
--- @param t any Value to check
--- @return boolean true if t is a windowfilter
function windowfilter.iswf(t)
  return type(t) == 'table' and t._filter ~= nil and t._subscriptions ~= nil
end

--- hs.window.filter.setLogLevel(lvl)
--- Function
--- Sets the log level for the window filter module.
--- @param lvl string|number Log level ('verbose', 'debug', 'info', 'warning', 'error', 'nothing')
function windowfilter.setLogLevel(lvl)
  log.setLogLevel(lvl)
end

--- hs.window.filter.getLogLevel() -> number
--- Function
--- Gets the current log level for the window filter module.
--- @return number The current log level (0=nothing, 1=error, 2=warning, 3=info, 4=debug, 5=verbose)
function windowfilter.getLogLevel()
  return log.getLogLevel()
end

--- hs.window.filter.switchedToSpace(space)
--- Function
--- Manually notify the module of a space change.
--- Use this when the system doesn't detect space changes automatically.
--- @param space number Space number (currently unused)
function windowfilter.switchedToSpace(space)
  local manager = Manager.getInstance()
  if manager:isRunning() then
    manager:_handleSpaceChange()
  end
end

-- Batch operations for ensuring tracker runs during multiple operations
local batches = {}

--- hs.window.filter.startBatchOperation() -> string
--- Function
--- Start a batch operation (keeps tracker running).
--- @return string Batch ID to pass to stopBatchOperation
function windowfilter.startBatchOperation()
  local id = tostring(timer.secondsSinceEpoch()) .. tostring(math.random(100000))
  batches[id] = true
  -- Ensure manager is running
  local manager = Manager.getInstance()
  if not manager:isRunning() then
    manager:_start()
  end
  return id
end

--- hs.window.filter.stopBatchOperation(id)
--- Function
--- Stop a batch operation.
--- @param id string Batch ID from startBatchOperation
function windowfilter.stopBatchOperation(id)
  batches[id] = nil
  -- If no more batches and no active instances, stop
  if not next(batches) then
    local manager = Manager.getInstance()
    if manager.instanceCount == 0 then
      manager:_stop()
    end
  end
end

----------------------------------------------------------------------
-- SECTION 14: DIRECTION AND FOCUS METHODS
----------------------------------------------------------------------

-- Sort a list of hs.window objects by actual z-order (frontmost first).
-- windowsInDirection() uses position in the candidate list as a z-order proxy
-- (position 1 = frontmost). Using timeFocused order doesn't work because
-- z-order can change without focus events (e.g., Cmd+Tab brings all of an
-- app's windows to front, but only the focused window's timeFocused updates).
local function sortByZOrder(windows)
  local orderedIds = hs.window._orderedwinids()
  local zIndex = {}
  for i, id in ipairs(orderedIds) do
    zIndex[id] = i
  end
  local sorted = {}
  for i, w in ipairs(windows) do sorted[i] = w end
  tsort(sorted, function(a, b)
    local aid = a:id() or 0
    local bid = b:id() or 0
    return (zIndex[aid] or 99999) < (zIndex[bid] or 99999)
  end)
  return sorted
end

-- Add direction methods to WindowFilter using loop to avoid repetition
local windowMT = hs.getObjectMetatable("hs.window")
for _, dir in ipairs{'East', 'North', 'West', 'South'} do
  -- windowsToEast/North/West/South
  WindowFilter['windowsTo' .. dir] = function(self, win, ...)
    return windowMT['windowsTo' .. dir](win, sortByZOrder(self:getWindows()), ...)
  end
  -- focusWindowEast/North/West/South
  WindowFilter['focusWindow' .. dir] = function(self, win, ...)
    if windowMT['focusWindow' .. dir](win, sortByZOrder(self:getWindows()), ...) then
      return true
    end
    return false
  end
  -- Module-level focusEast/North/West/South
  windowfilter['focus' .. dir] = function()
    local wf = makeDefaultCurrentSpace()
    wf:keepActive()
    wf['focusWindow' .. dir](wf, nil, nil, true)
  end
end

----------------------------------------------------------------------
-- RETURN MODULE WITH METATABLE
----------------------------------------------------------------------

local rawget = rawget
return setmetatable(windowfilter, {
  -- Lazy singletons via __index
  __index = function(t, k)
    if k == 'default' then
      return makeDefault()
    elseif k == 'defaultCurrentSpace' then
      return makeDefaultCurrentSpace()
    else
      return rawget(t, k)
    end
  end,
  -- Module callable: windowfilter(...) -> windowfilter.new(...):getWindows()
  __call = function(_, ...)
    return windowfilter.new(...):getWindows()
  end,
})
