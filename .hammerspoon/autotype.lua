local log = hs.logger.new("autotype", "debug")

----- autotype sign in -----
hs.urlevent.bind("autotypeSignIn", function(eventName, params)
  log.d("autotypeSignIn")
    hs.eventtap.keyStrokes(params.u)
    hs.eventtap.keyStroke({}, "Tab")
    hs.eventtap.keyStrokes(params.p)
end)
