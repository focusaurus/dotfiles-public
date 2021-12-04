local module = {}
local log = hs.logger.new("journal", "debug")
-- local windowManagement = require("window-management")
local fuzzball = os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball"

-- local function journalVim()
--   log.d("journalVim")
--   hs.application.launchOrFocus("iTerm")
--   local windows = hs.application.frontmostApplication():allWindows()
--   for _, window in pairs(windows) do
--     if window:title() == "journal mailchimp" then
--       log.d("focusing existing journal window")
--       window:focus()
--       return
--     end
--   end
--   hs.timer.doAfter(0.2, function()
--     hs.eventtap.keyStroke({"command", "control"}, "j")
--     hs.timer.doAfter(0.5, function()
--       log.d("about to bottomRight")
--       windowManagement.bottomRight()
--     end)
--   end)
-- end

function module.appendByDialog()
  log.d("appendByDialog")
  os.execute(fuzzball .. "/journal-intuit &")
end

function module.appendByDialogStandup()
  log.d("appendByDialogStandup")
  os.execute(fuzzball .. "/journal-intuit-standup &")
end

function module.appendInTerminalWindow()
  log.d("appendInTerminalWindow")
  os.execute(fuzzball .. "/in-journal-vim &")
end

return module
