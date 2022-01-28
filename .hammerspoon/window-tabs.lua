vsCode = hs.application.get("com.microsoft.VSCode")

if vsCode ~= nil then
  hs.tabs.enableForApp(vsCode)
end
