local default_environment = {
    repl = false
}

function initialize_filesystem(id)
    -- create filesystem if it doesn't already exist
    if not global.fs then
        global.fs = {}
    end
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
            environment = default_environment
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

function clear_stdout(id)
    global.fs[id].output.stdout.contents = ""
    global.fs[id].output.stdout.cursor = 1
end

function prompt(id)
    if not global.fs[id].environment.repl then
        stdout(id, "engineer@nauvisos:~$ ")
    else
        stdout(id, "engineer@nauvisos [REPL]:~$ ")
    end
end

function help(id)
    stdout(id, "  1.  help - display this help message\n")
    stdout(id, "  2.  clear - clear the terminal\n")
    stdout(id, "  3.  repl - enter the nauvis os repl environment\n")
end

function clear(id)
    clear_stdout(id)
end

function repl(id)
    if not global.fs[id].environment.repl then
        global.fs[id].environment.repl = true
        stdout(id, "Entering REPL environment. Type 'exit' to exit.\n")
    end
end

-- name is the name of the terminal we're booting
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
