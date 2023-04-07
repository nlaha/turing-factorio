-- close button logic
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)
    local screen_element = player.gui.screen
    local computer_frame_outer = screen_element["tf_computer_frame_outer"]
    if computer_frame_outer then
        if event.element.name == "tf_close_button" then
            computer_frame_outer.destroy()
        end
    end
end)

-- check if player is typing in the terminal
script.on_event(defines.events.on_gui_text_changed, function(event)
    local player = game.get_player(event.player_index)
    local screen_element = player.gui.screen
    local computer_frame_outer = screen_element["tf_computer_frame_outer"]
    if computer_frame_outer then
        if event.element.name == "tf_terminal_text" then
            -- make sure the user doesn't erase any previous output that 
            -- was written to stdout

            -- get length of stdout
            local stdout_length = string.len(global.fs.output.stdout.contents)

            -- get substring from start of text to end of stdout
            local text = string.sub(event.element.text, 1, stdout_length)

            -- get rest of text
            local rest = string.sub(event.element.text, stdout_length + 1)

            -- if it doesn't match, reset the text to the previous value
            if text ~= global.fs.output.stdout.contents then
                event.element.text = global.fs.output.stdout.contents .. rest
            end

            -- if the player presses enter, push the input from stdout_length + 1 to the end
            -- of the text to stdin
            if event.element.text:sub(-1) == "\n" then
                -- get input from cursor location to end of text
                local input = string.sub(event.element.text, stdout_length + 1)

                -- remove newline character
                input = string.sub(input, 1, -2)

                -- write input to stdin and stdout
                global.fs.input.stdin.contents = input
                stdout(input .. "\n")

                local success = false
                local err = ""

                if global.fs.environment.repl then
                    if input == "exit" then
                        global.fs.environment.repl = false
                        stdout("Exiting REPL environment.")
                    else
                        -- execute lua code
                        success, err = pcall(function()
                            local out = assert(loadstring("return " .. input))() .. "\n"
                            stdout(out)
                        end)
                    end
                else
                    -- run the command
                    success, err = pcall(function()
                        _G[input]()
                    end)
                end

                -- if there was an error, print it to stdout
                if not success then
                    stdout(err .. "\n")
                end

                -- regardless of status, print the prompt
                prompt()

                -- update the text
                event.element.text = global.fs.output.stdout.contents
            end
        end
    end
end)

