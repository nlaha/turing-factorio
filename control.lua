require "terminal/os"
require "terminal/events"
require "terminal/gui"

-- Make sure the intro cinematic of freeplay doesn't play every time we restart
script.on_init(function()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then
            remote.call("freeplay", "set_skip_intro", true)
        end
        if freeplay["set_disable_crashsite"] then
            remote.call("freeplay", "set_disable_crashsite", true)
        end
    end

    initialize_filesystem()
end)

