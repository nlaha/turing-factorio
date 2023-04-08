local default_environment = {
    repl = false,
    editing = false,
    current_file = nil
}

function initialize_filesystem(id)
    -- create filesystem if it doesn't already exist
    if not global.fs[id] then
        global.fs[id] = {
            input = {
                stdin = {
                    contents = "",
                    cursor = 1
                }
            },
            output = {
                stdout = {
                    contents = "",
                    cursor = 1
                }
            },
            environment = default_environment,
            files = {},
            network_output = {},
            network_input = {}
        }
    end
end

function destroy_filesystem(id)
    global.fs[id] = nil
end

function reset_environment(id)
    global.fs[id].environment = default_environment
end

-- function to write to stdout
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

-- function to clear stdout
function clear_stdout(id)
    global.fs[id].output.stdout.contents = ""
    global.fs[id].output.stdout.cursor = 1
end

-- function to write to stdin
function prompt(id)
    if not global.fs[id].environment.repl then
        stdout(id, "engineer@nauvisos:~$ ")
    else
        stdout(id, "engineer@nauvisos [REPL]:~$ ")
    end
end

-- command to display help
function help(id)
    stdout(id, "  1.  help - display this help message\n")
    stdout(id, "  2.  clear - clear the terminal\n")
    stdout(id, "  3.  repl - enter the nauvis os repl environment\n")
    stdout(id, "  4.  edit <filename> - edit a file\n")
    stdout(id, "  5.  run <filename> - run a file\n")
    stdout(id, "  6.  ls - list files\n")
    stdout(id, "  7.  cat <filename> - display the contents of a file\n")
    stdout(id, "  8.  rm <filename> - remove a file\n")
    stdout(id, "  9.  flash <filename> <ip address/serial port>\n")
end

-- command to edit a file
function edit(id, args)

    local filename = args[1]
    -- if the file doesn't exist, create it
    -- check if filename is nil
    if not filename then
        stdout(id, "Error: no filename specified.\n")
        return
    end

    if not global.fs[id].files[filename] then
        global.fs[id].files[filename] = {
            contents = "",
            cursor = 1
        }
    end

    -- set the current file to the file we're editing
    global.fs[id].environment.current_file = filename

    -- clear stdout
    clear_stdout(id)

    -- write the contents of the file to stdout
    stdout(id, global.fs[id].files[filename].contents)

    -- set the cursor to the end of the file
    global.fs[id].files[filename].cursor = string.len(global.fs[id].files[filename].contents)

    -- switch into editing mode
    global.fs[id].environment.editing = true

end

--- clears the terminal
---@param id any
function clear(id)
    clear_stdout(id)
end

--- prints the working directory
---@param id any
function ls(id)
    for k, v in pairs(global.fs[id].files) do
        stdout(id, k .. "\n")
    end
end

--- prints the contents of a file
---@param id any
---@param args any
function cat(id, args)
    local filename = args[1]
    if not filename then
        stdout(id, "Error: no filename specified.\n")
        return
    end

    if not global.fs[id].files[filename] then
        stdout(id, "Error: file " .. filename .. " does not exist.\n")
        return
    end

    stdout(id, global.fs[id].files[filename].contents)
end

--- deletes a file
---@param id any
---@param args any
function rm(id, args)
    local filename = args[1]
    if not filename then
        stdout(id, "Error: no filename specified.\n")
        return
    end

    if not global.fs[id].files[filename] then
        stdout(id, "Error: file " .. filename .. " does not exist.\n")
        return
    end

    global.fs[id].files[filename] = nil
end

--- executes the file locally
---@param id any
---@param args any
function run(id, args)
    local filename = args[1]
    if not filename then
        stdout(id, "Error: no filename specified.\n")
        return
    end

    if not global.fs[id].files[filename] then
        stdout(id, "Error: file " .. filename .. " does not exist.\n")
        return
    end

    -- clear stdout
    clear_stdout(id)

    -- run the file using loadstring
    local success, err = loadstring(global.fs[id].files[filename].contents, filename)
    if not success then
        stdout(id, "Error: " .. err .. "\n")
        return
    end

    success()
end

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
    signals = entity.get_circuit_network(wire).signals

    -- if the signal is nil, return
    if not signals then
        return
    end

    -- return the signal
    return signals[signal]
end

-- command to enter the repl environment
---@param id any
function repl(id)
    if not global.fs[id].environment.repl then
        global.fs[id].environment.repl = true
        stdout(id, "Entering REPL environment. Type 'exit' to exit.\n")
    end
end

-- name is the name of the terminal we're booting
---@param id any
function boot_os(id)
    -- clear stdout
    clear_stdout(id)

    -- reset environment
    reset_environment(id)

    -- write a welcome message to stdout
    stdout(id, "NauvisOS v0.0.1\nWelcome!\nType 'help' for a list of commands.\n")

    stdout(id, "Memory initialized.\n")
    prompt(id)
end

--- called in text update when in file editing mode
---@param e any
---@param hash any
function handle_editing(e, hash)
    -- allow the user to make changes to stdout
    global.fs[hash].output.stdout.contents = e.element.text
end

--- function to handle the shell, called in text update
---@param e any
---@param hash any
---@return any
function handle_shell(e, hash)
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
            -- newline
            stdout(hash, "\n")
            -- prompt
            prompt(hash)
            -- update the text
            e.element.text = global.fs[hash].output.stdout.contents
            return
        end

        -- split input by spaces
        local command = strsplit(input, " ")[1]
        local arguments = strsplit(input, " ")
        -- remove the command from the arguments
        table.remove(arguments, 1)

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
                -- first argument is the id of the terminal we currently have open
                _G[command](hash, arguments)
            end)
        end

        -- if there was an error, print it to stdout
        if not success then
            stdout(hash, err .. "\n")
        end

        -- regardless of status, print the prompt
        -- unless we're in editing mode
        if not global.fs[hash].environment.editing then
            prompt(hash)
        end

        -- update the text
        e.element.text = global.fs[hash].output.stdout.contents
    end
end
