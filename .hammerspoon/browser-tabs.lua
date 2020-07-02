local log = hs.logger.new("browser-tabs", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function browserTabs() 
  hs.application.launchOrFocus("Google Chrome")
  hs.application.frontmostApplication():selectMenuItem({"Tab"})
end

hs.urlevent.bind("browserTabs", browserTabs)
