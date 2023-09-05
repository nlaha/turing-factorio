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

local function update_gui(self)
    local player = self.player
    local screen_element = player.gui.screen
    local computer_frame_outer = screen_element["tf_computer_frame_outer"]
    local computer_frame_content = computer_frame_outer["tf_computer_frame_content"]
    local computer_frame = computer_frame_content["tf_computer_frame"]
    local terminal_text = computer_frame["tf_terminal_text"]
    local hash = util.hash_entity(self.entity)
    local stdout = global.fs[hash].output.stdout.contents
    terminal_text.text = stdout
end

-- define handlers for GUI events
local handlers = {

    on_cancel = function(self, e)
        -- if we're in editing mode, cancel the edit
        local hash = util.hash_entity(self.entity)
        if global.fs[hash].environment.editing then
            -- disable editing mode
            global.fs[hash].environment.editing = false
            -- clear stdout
            clear_stdout(hash)
            -- prompt
            prompt(hash)

            update_gui(self)
        end
    end,

    on_save = function(self, e)
        -- if we're in editing mode, save the file
        local hash = util.hash_entity(self.entity)
        if global.fs[hash].environment.editing then
            local file = global.fs[hash].environment.current_file
            -- get stdout
            local stdout = global.fs[hash].output.stdout.contents
            -- write to file
            global.fs[hash].contents[file].contents = stdout

            -- disable editing mode
            global.fs[hash].environment.editing = false
            -- clear stdout
            clear_stdout(hash)
            -- prompt
            prompt(hash)

            -- update gui text
            update_gui(self)
        end
    end,

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
        local hash = util.hash_entity(self.entity)
        if computer_frame_outer then
            if e.element.name == "tf_terminal_text" then
                if global.fs[hash].environment.editing then
                    handle_editing(e, hash)
                else
                    handle_shell(e, hash)
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

    local hash = util.hash_entity(entity)
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
            },
            {
                type = "frame",
                name = "tf_computer_frame_functions",
                style = "entity_frame",
                direction = "horizontal",
                -- save button
                {
                    type = "sprite-button",
                    name = "tf_save_button",
                    style = "frame_action_button",
                    sprite = "utility/check_mark_white",
                    hovered_sprite = "utility/check_mark",
                    clicked_sprite = "utility/check_mark",
                    tooltip = {"tf.save_button_tooltip"},
                    mouse_button_filter = {"left"},
                    handler = {
                        [defines.events.on_gui_click] = handlers.on_save
                    }
                },
                -- cancel button
                {
                    type = "sprite-button",
                    name = "tf_cancel_button",
                    style = "frame_action_button",
                    sprite = "utility/reset_white",
                    hovered_sprite = "utility/reset",
                    clicked_sprite = "utility/reset",
                    tooltip = {"tf.cancel_button_tooltip"},
                    mouse_button_filter = {"left"},
                    handler = {
                        [defines.events.on_gui_click] = handlers.on_cancel
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
