-- The terminal is a powerful computer designed to be the main control center for your factory
-- connect to microcontrollers over the network to control your factory
local entity = table.deepcopy(data.raw["lamp"]["small-lamp"]) -- we'll use a lamp as our template
local item = table.deepcopy(data.raw['item']["small-lamp"]) -- we'll use a lamp as our template

item.icon = "__turing-factorio__/graphics/icons/terminal_icon.png"
item.icon_size = 128
item.name = "tf-computer-terminal"
item.place_result = "tf-computer-terminal"
item.subgroup = "circuit-network"

entity.name = "tf-computer-terminal"
entity.type = "lamp"
entity.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
entity.picture_on = {
    layers = {{
        filename = "__turing-factorio__/graphics/terminal_on.png",
        priority = "high",
        width = 384,
        height = 384,
        shift = {0, 0},
        scale = 1
    }}
}
entity.picture_off = {
    layers = {{
        filename = "__turing-factorio__/graphics/terminal_off.png",
        priority = "high",
        width = 384,
        height = 384,
        shift = {0, 0},
        scale = 1
    }}
}

entity.collision_box = {{-3, -3}, {3, 3}}
entity.selection_box = {{-3, -3}, {3, 3}}
entity.drawing_box = {{-3, -3}, {3, 3}}
entity.corpse = "assembling-machine-3-remnants" -- TODO make a corpse
entity.dying_explosion = "assembling-machine-3-explosion" -- TODO make an explosion
entity.energy_usage_per_tick = "1KW"
entity.minable = {
    mining_time = 1.0,
    result = "tf-computer-terminal"
}
entity.placeable_by = {
    item = "tf-computer-terminal",
    count = 1
}
entity.light = {
    intensity = 0,
    type = "basic",
    size = 0
}
entity.circuit_wire_connection_point = {
    wire = {
        copper = {-2.8, -1},
        green = {-2.8, -1},
        red = {-2.8, -1}
    },
    shadow = {
        copper = {-2.8, -1},
        green = {-2.8, -1},
        red = {-2.8, -1}
    }
}
entity.circuit_connector_sprites.wire_pins = {
    filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04a-base-sequence.png",
    height = 58,
    priority = "low",
    scale = 0.5,
    shift = {-2.5, -1.0},
    width = 58,
    x = 0,
    y = 104
}

entity.circuit_connector_sprites.led_red.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.led_green.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.led_blue.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.connector_main.shift = {-1.0, -0.25}

local recipe = table.deepcopy(data.raw["recipe"]["small-lamp"])
recipe.enabled = true
recipe.name = "tf-computer-terminal"
recipe.ingredients = {{"advanced-circuit", 200}, {"steel-plate", 50}}
recipe.result = "tf-computer-terminal"
recipe.category = "advanced-crafting"
recipe.subgroup = "circuit-network"

data:extend{item, entity, recipe}
