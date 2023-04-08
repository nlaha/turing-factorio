--- @class Util
local util = {}

local coreutil = require("__core__/lualib/util")
util.parse_energy = coreutil.parse_energy

--- @param handler GuiElemHandler
function util.close_button(handler)
    return {
        type = "sprite-button",
        style = "frame_action_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = {"gui.close-instruction"},
        mouse_button_filter = {"left"},
        handler = {
            [defines.events.on_gui_click] = handler
        }
    }
end

function util.pusher()
    return {
        type = "empty-widget",
        style = "flib_horizontal_pusher",
        ignored_by_interaction = true
    }
end

--- @param player LuaPlayer
--- @param message LocalisedString
--- @param play_sound boolean?
--- @param position MapPosition?
function util.flying_text(player, message, play_sound, position)
    player.create_local_flying_text({
        text = message,
        create_at_cursor = not position,
        position = position
    })
    if play_sound then
        player.play_sound({
            path = "utility/cannot_build"
        })
    end
end

--- @param e EventData.on_player_setup_blueprint
--- @return LuaItemStack?
function util.get_blueprint(e)
    local player = game.get_player(e.player_index)
    if not player then
        return
    end

    local bp = player.blueprint_to_setup
    if bp and bp.valid_for_read then
        return bp
    end

    bp = player.cursor_stack
    if not bp or not bp.valid_for_read then
        return
    end

    if bp.type == "blueprint-book" then
        local item_inventory = bp.get_inventory(defines.inventory.item_main)
        if item_inventory then
            bp = item_inventory[bp.active_index]
        else
            return
        end
    end

    return bp
end

--- returns a unique string hash for an entity
--- precondition: entity is valid
--- @param entity LuaEntity
function hash_entity(entity)
    return entity.name .. ":" .. entity.position.x .. ":" .. entity.position.y
end

return util
