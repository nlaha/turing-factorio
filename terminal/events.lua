require("terminal/gui")
require("terminal/os")

entity_names = {
    ["tf-computer-terminal"] = true
}

local function on_gui_opened(e)
    if e.gui_type ~= defines.gui_type.entity then
        return
    end
    local entity = e.entity
    if not entity or not entity.valid or not entity_names[entity.name] then
        return
    end
    local player = game.get_player(e.player_index)
    if not player then
        return
    end

    destroy_gui(player.index)
    local gui = create_gui(player, entity)

    player.opened = gui.tf_computer_frame_outer

    -- focus on the text box
    player.gui.screen.tf_computer_frame_outer.tf_computer_frame_content.tf_computer_frame.tf_terminal_text.focus()
end

local function on_entity_destroyed(e)
    local entity = e.entity
    if not entity.valid or not entity_names[entity.name] then
        return
    end

    -- destroy filesystem for the hash of the entity
    local hash = hash_entity(entity)
    destroy_filesystem(hash)

    for player_index, gui in pairs(global.tf_terminal_gui) do
        if gui.entity == entity then
            destroy_gui(player_index)
        end
    end
end

local entity = {}

entity.on_configuration_changed = function()
    for player_index in pairs(game.players) do
        destroy_gui(player_index)
    end
end

entity.on_init = function()
    global.tf_terminal_gui = {}
end

local function on_built_entity(e)
    -- create a filesystem for the hash of the entity
    local hash = hash_entity(e.created_entity)
    initialize_filesystem(hash)
    boot_os(hash)
end

entity.events = {
    [defines.events.on_entity_died] = on_entity_destroyed,
    [defines.events.on_gui_opened] = on_gui_opened,
    [defines.events.on_player_mined_entity] = on_entity_destroyed,
    [defines.events.on_robot_mined_entity] = on_entity_destroyed,
    [defines.events.script_raised_destroy] = on_entity_destroyed,
    [defines.events.on_built_entity] = on_built_entity
}

return entity
