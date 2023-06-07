require("__turing-factorio__/tf_scripting_api")

local default_environment = {
    repl = false,
    editing = false,
    current_file = nil
}

local script_prefix = [[

]]

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
    stdout(id, [[
Welcome to the Nauvis OS help page.
Type "man <command>" to get help on a specific command.
Available commands:
help, clear, repl, edit, run, ls, cat, rm, flash, mkdir, cd
    ]])
end

function man(id, args)
    local cmdname = args[1]

    if not cmdname then
        stdout(id, "Error: no command specified.\n")
        return
    end

    if cmdname == "help" then
        stdout(id, "help - display this help message\n")

    elseif cmdname == "clear" then
        stdout(id, "clear - clear the terminal\n")
        
    elseif cmdname == "repl" then
        stdout(id, "repl - enter the nauvis os repl environment\n")
    
    elseif cmdname == "edit" then
        stdout(id, "edit <filename> - edit a file\n")
    
    elseif cmdname == "run" then
        stdout(id, "run <filename> - run a file\n")
    
    elseif cmdname == "ls" then
        stdout(id, "ls - list files\n")
    
    elseif cmdname == "cat" then
        stdout(id, "cat <filename> - display the contents of a file\n")
    
    elseif cmdname == "rm" then
        stdout(id, "rm <filename> - remove a file\n")
    
    elseif cmdname == "flash" then
        stdout(id, "flash <filename> <ip address/serial port>\n")
    
    elseif cmdname == "mkdir" then
        stdout(id, "mkdir <dirname> - create a directory\n")

    elseif cmdname == "cd" then
        stdout(id, "cd <dirname> - change directory\n")
    else
        stdout(id, "Error: command " .. cmdname .. " not found.\n")
    end

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

--- creates a directory
---@param id any
---@param args any
function mkdir(id, args)
    local dirname = args[1]
    if not dirname then
        stdout(id, "Error: no directory name specified.\n")
        return
    end

    if global.fs[id].files[dirname] then
        stdout(id, "Error: file or directory " .. dirname .. " already exists.\n")
        return
    end

    global.fs[id].files[dirname] = {
        contents = {},
        directory = true
    }
end

-- changes the current directory
---@param id any
---@param args any
function cd(id, args)
    local dirname = args[1]
    if not dirname then
        stdout(id, "Error: no directory name specified.\n")
        return
    end

    if not global.fs[id].files[dirname].directory then
        stdout(id, "Error: " .. dirname .. " is not a directory.\n")
        return
    end

    if not global.fs[id].files[dirname] then
        stdout(id, "Error: directory " .. dirname .. " does not exist.\n")
        return
    end

    global.fs[id].environment.current_directory = dirname
end

--- deletes a file or directory
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
    local success, err = loadstring(script_prefix .. global.fs[id].files[filename].contents, filename)
    if not success then
        stdout(id, "Error: " .. err .. "\n")
        return
    end

    success()
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

-- function to handle the shutdown command
---@param id any
function shutdown(id)
    -- print goodbye message
    stdout(id, "System going into hardware shutdown mode, goodbye!\n")

    -- get entity with given id
    local entity = entity_from_hash(id)

    -- set power consumption to 0
    entity.electric_buffer_size = 0

    -- clear stdout
    clear_stdout(id)

    -- reset environment
    reset_environment(id)

    -- set power state flag in environment
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
                    local out = assert(loadstring(script_prefix .. "return " .. input))() .. "\n"
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
