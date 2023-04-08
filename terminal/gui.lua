local gui = require("__flib__/gui-lite")
local util = require("__turing-factorio__/util")

function destroy_gui(player_index)
    local self = global.tf_terminal_gui[player_index]
    if not self then
        return
    end
    global.tf_terminal_gui[player_index] = nil
    local window = self.elems.tf_computer_frame_outer
    if not window.valid then
        return
    end
    window.destroy()
end

-- define handlers for GUI events
local handlers = {

    on_gui_closed = function(self, e)
        destroy_gui(e.player_index)
        local player = self.player
        if not player.valid then
            return
        end
    end,

    -- check if player is typing in the terminal
    on_gui_text_changed = function(self, e)
        local player = game.get_player(e.player_index)
        local screen_element = player.gui.screen
        local computer_frame_outer = screen_element["tf_computer_frame_outer"]
        local hash = hash_entity(self.entity)
        if computer_frame_outer then
            if e.element.name == "tf_terminal_text" then
                -- make sure the user doesn't erase any previous output that 
                -- was written to stdout

                -- get length of stdout
                local stdout_length = string.len(global.fs[hash].output.stdout.contents)

                -- get substring from start of text to end of stdout
                local text = string.sub(e.element.text, 1, stdout_length)

                -- get rest of text
                local rest = string.sub(e.element.text, stdout_length + 1)

                -- if it doesn't match, reset the text to the previous value
                if text ~= global.fs[hash].output.stdout.contents then
                    e.element.text = global.fs[hash].output.stdout.contents .. rest
                end

                -- if the player presses enter, push the input from stdout_length + 1 to the end
                -- of the text to stdin
                if e.element.text:sub(-1) == "\n" then
                    -- get input from cursor location to end of text
                    local input = string.sub(e.element.text, stdout_length + 1)

                    -- remove newline character
                    input = string.sub(input, 1, -2)
                    -- trim whitespace
                    input = string.gsub(input, "^%s*(.-)%s*$", "%1")

                    -- if the input is empty, don't do anything
                    if input == "" then
                        return
                    end

                    -- write input to stdin and stdout
                    global.fs[hash].input.stdin.contents = input
                    stdout(hash, input .. "\n")

                    local success = false
                    local err = ""

                    if global.fs[hash].environment.repl then
                        if input == "exit" then
                            global.fs[hash].environment.repl = false
                            stdout(hash, "Exiting REPL environment.")
                        else
                            -- execute lua code
                            success, err = pcall(function()
                                local out = assert(loadstring("return " .. input))() .. "\n"
                                stdout(hash, out)
                            end)
                        end
                    else
                        -- run the command
                        success, err = pcall(function()
                            _G[input](hash) -- argument is the id of the terminal we currently have open
                        end)
                    end

                    -- if there was an error, print it to stdout
                    if not success then
                        stdout(hash, err .. "\n")
                    end

                    -- regardless of status, print the prompt
                    prompt(hash)

                    -- update the text
                    e.element.text = global.fs[hash].output.stdout.contents
                end
            end
        end
    end
}

gui.add_handlers(handlers, function(e, handler)
    local self = global.tf_terminal_gui[e.player_index]
    if not self then
        return
    end
    if not self.entity.valid then
        return
    end

    handler(self, e)
end)

-- create computer GUI
function create_gui(player, entity)

    local hash = hash_entity(entity)
    local elems = gui.add(player.gui.screen, {
        type = "frame",
        name = "tf_computer_frame_outer",
        style = "machine_frame",
        direction = "vertical",
        elem_mods = {
            auto_center = true
        },
        handler = {
            [defines.events.on_gui_closed] = handlers.on_gui_closed
        },
        {
            type = "flow",
            style = "flib_titlebar_flow",
            drag_target = "tf_computer_frame_outer",
            {
                type = "label",
                style = "frame_title",
                caption = {"tf.global_menu_caption"},
                ignored_by_interaction = true
            },
            {
                type = "empty-widget",
                style = "flib_titlebar_drag_handle",
                ignored_by_interaction = true
            },
            util.close_button(handlers.on_gui_closed)
        },
        {
            type = "frame",
            name = "tf_computer_frame_content",
            style = "entity_frame",
            direction = "vertical",
            {
                type = "frame",
                style = "deep_frame_in_shallow_frame",
                {
                    type = "entity-preview",
                    name = "entity_preview",
                    style = "wide_entity_button",
                    elem_mods = {
                        entity = entity
                    }
                }
            },
            {
                type = "frame",
                name = "tf_computer_frame",
                style = "tf_computer_frame",
                {
                    type = "text-box",
                    name = "tf_terminal_text",
                    text = global.fs[hash].output.stdout.contents,
                    style = "tf_terminal_text",
                    handler = {
                        [defines.events.on_gui_text_changed] = handlers.on_gui_text_changed
                    }
                }
            }
        }
    })

    local self = {
        elems = elems,
        entity = entity,
        player = player
    }
    global.tf_terminal_gui[player.index] = self

    return elems
end
