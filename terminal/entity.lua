-- The terminal is a powerful computer designed to be the main control center for your factory
-- connect to microcontrollers over the network to control your factory
local entity = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"]) -- we'll use a lamp as our template
local item = table.deepcopy(data.raw['item']["decider-combinator"]) -- we'll use a lamp as our template

item.icon = "__turing-factorio__/graphics/icons/terminal_icon.png"
item.icon_size = 128
item.name = "computer-terminal"
item.place_result = "computer-terminal"
item.subgroup = "circuit-network"

entity.sprites = {
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
entity.name = "computer-terminal"
entity.type = "decider-combinator"
entity.flags = {"placeable-neutral", "player-creation"}
entity.corpse = "assembling-machine-3-remnants" -- TODO make a corpse
entity.dying_explosion = "assembling-machine-3-explosion" -- TODO make an explosion
entity.energy_usage_per_tick = "1KW"
entity.minable = {
    mining_time = 1.0,
    result = "computer-terminal"
}
entity.placeable_by = {
    item = "computer-terminal",
    count = 1
}

local recipe = table.deepcopy(data.raw["recipe"]["decider-combinator"])
recipe.enabled = true
recipe.name = "computer-terminal"
recipe.ingredients = {{"advanced-circuit", 200}, {"steel-plate", 50}}
recipe.result = "computer-terminal"
recipe.category = "advanced-crafting"
recipe.subgroup = "circuit-network"

data:extend{item, entity, recipe}
