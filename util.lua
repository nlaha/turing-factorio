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

function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
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
function util.hash_entity(entity)
    return entity.name .. ":" .. entity.position.x .. ":" .. entity.position.y
end

--- returns an entity from a hash
function util.entity_from_hash(hash)
    local name, x, y = strsplit(hash, ":")
    return game.surfaces[1].find_entity(name, {tonumber(x), tonumber(y)})
end

--- splits a path into its components
function util.split_path(path)
    local components = {}
    for component in string.gmatch(path, "[^/]+") do
        table.insert(components, component)
    end
    return components
end

function util.get_dir_from_path(id, path)

    if global.fs[id].environment.current_directory == nil then
        global.fs[id].environment.current_directory = {
            name = "",
            contents = global.fs[id].contents,
            parent = nil
        }
    end

    local current_dir = global.fs[id].environment.current_directory
    local error_not_dir = false

    -- split dirname by /
    local split_dirname = util.split_path(path)
    -- while there are still directories to traverse
    for i = 1, #split_dirname do
        -- if the directory is .., go up a directory
        if split_dirname[i] == ".." then
            current_dir = current_dir.parent
            if not current_dir then
                error_not_dir = true
                break
            end
        -- if the directory is ., do nothing
        elseif split_dirname[i] == "." then
            current_dir = current_dir
        -- otherwise, go down a directory
        else
            current_dir = current_dir.contents[split_dirname[i]]
            if not current_dir then
                error_not_dir = true
                break
            end
        end
    end

    if error_not_dir then
        stdout(id, "Error: " .. path .. " is not a directory.\n")
        return
    end

    return current_dir
end

return util
