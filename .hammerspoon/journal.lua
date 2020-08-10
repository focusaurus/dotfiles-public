local log = hs.logger.new("journal", "debug")
local windowManagement = require("window-management")
local fuzzball = os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball"

----- journal -----
local function journalVim()
  log.d("journalVim")
  hs.application.launchOrFocus("iTerm")
  local windows = hs.application.frontmostApplication():allWindows()
  for _, window in pairs(windows) do
    if window:title() == "journal mailchimp" then
      log.d("focusing existing journal window")
      window:focus()
      return
    end
  end
  hs.timer.doAfter(0.2, function()
    hs.eventtap.keyStroke({"command", "control"}, "j")
    hs.timer.doAfter(0.5, function()
      log.d("about to bottomRight")
      windowManagement.bottomRight()
    end)
  end)
end
-- hs.hotkey.bind({"command"}, "j", journalVim)

local function journalDialog()
  log.d("journalDialog")
  os.execute(fuzzball .. "/journal-mailchimp")
end
hs.hotkey.bind({}, "f9", journalDialog)

local function journalStandupDialog()
  log.d("journalStandupDialog")
  os.execute(fuzzball .. "/journal-mailchimp-standup")
end
hs.hotkey.bind({"shift"}, "f9", journalStandupDialog)

