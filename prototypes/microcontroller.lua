-- The microcontroller is a small computer designed to run a single program asynchronusly
-- it can interact with the circuit network and other microcontrollers
local entity = table.deepcopy(data.raw["lamp"]["small-lamp"]) -- we'll use a lamp as our template
local item = table.deepcopy(data.raw['item']["small-lamp"]) -- we'll use a lamp as our template

item.icon = "__turing-factorio__/graphics/icons/microcontroller_icon.png"
item.icon_size = 62
item.name = "tf-microcontroller"
item.place_result = "tf-microcontroller"
item.subgroup = "circuit-network"

entity.name = "tf-microcontroller"
entity.type = "lamp"
entity.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
entity.picture_on = {
    layers = {{
        filename = "__turing-factorio__/graphics/microcontroller_on.png",
        priority = "high",
        width = 256,
        height = 256,
        shift = {0, 0},
        scale = 1
    }}
}
entity.picture_off = {
    layers = {{
        filename = "__turing-factorio__/graphics/microcontroller_off.png",
        priority = "high",
        width = 256,
        height = 256,
        shift = {0, 0},
        scale = 1
    }}
}

entity.collision_box = {{-1, -1}, {1, 1}}
entity.selection_box = {{-1, -1}, {1, 1}}
entity.drawing_box = {{-1, -1}, {1, 1}}
entity.corpse = "iron-chest-remnants" -- TODO make a corpse
entity.dying_explosion = "iron-chest-explosion" -- TODO make an explosion
entity.energy_usage_per_tick = "1KW"
entity.minable = {
    mining_time = 1.0,
    result = "tf-microcontroller"
}
entity.placeable_by = {
    item = "tf-microcontroller",
    count = 1
}
entity.light = {
    intensity = 0,
    type = "basic",
    size = 0
}
entity.circuit_wire_connection_point = {
    wire = {
        copper = {1.0, -1},
        green = {1.0, -1},
        red = {1.0, -1}
    },
    shadow = {
        copper = {1.0, -1},
        green = {1.0, -1},
        red = {1.0, -1}
    }
}
entity.circuit_connector_sprites.wire_pins = {
    filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04a-base-sequence.png",
    height = 58,
    priority = "low",
    scale = 0.5,
    shift = {1.0, 2.0},
    width = 58,
    x = 0,
    y = 0
}

entity.circuit_connector_sprites.led_red.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.led_green.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.led_blue.shift = {-1.0, -0.25}
entity.circuit_connector_sprites.connector_main.shift = {-1.0, -0.25}

local recipe = table.deepcopy(data.raw["recipe"]["small-lamp"])
recipe.enabled = true
recipe.name = "tf-microcontroller"
recipe.ingredients = {{"advanced-circuit", 200}, {"steel-plate", 50}}
recipe.result = "tf-microcontroller"
recipe.category = "advanced-crafting"
recipe.subgroup = "circuit-network"

data:extend{item, entity, recipe}
