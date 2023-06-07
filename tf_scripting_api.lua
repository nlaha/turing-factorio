--- function to write a signal
---@param id any
---@param wire any
---@param signal any
function write_signal(id, wire, signal)
    -- gets the entity with the given id
    local entity = entity_from_hash(id)

    -- if the entity is nil, return
    if not entity then
        return
    end

    -- output signal on the given wire
    -- TODO: Change prototype type such that it has an output signal
    -- (we need the correct control behavior)
end

-- function to read a signal
---@param id any
---@param wire any
---@param signal any
function read_signal(id, wire, signal)
    -- gets the entity with the given id
    local entity = entity_from_hash(id)

    -- if the entity is nil, return
    if not entity then
        return
    end

    -- read signal on the given wire
    local signals = entity.get_circuit_network(wire).signals

    -- if the signal is nil, return
    if not signals then
        return
    end

    -- return the signal
    return signals[signal]
end

-- function to write to stdout
---@param id any
---@param input string
function stdout(id, input)
    if not global.fs[id] then
        game.print("Error: terminal " .. id .. " does not exist.")
    end

    -- write input from cursor location
    global.fs[id].output.stdout.contents = string.sub(global.fs[id].output.stdout.contents, 1,
            global.fs[id].output.stdout.cursor) .. input ..
        string.sub(global.fs[id].output.stdout.contents,
            global.fs[id].output.stdout.cursor + 1)

    -- add length of input to cursor
    global.fs[id].output.stdout.cursor = global.fs[id].output.stdout.cursor + string.len(input)
end

-- returns the current computer's identifier
---@param id any
function getid(id)
    return id
end