local default_environment = {
    repl = false
}

function initialize_filesystem()
    -- create filesystem if it doesn't already exist
    if not global.fs then
        global.fs = {
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

function reset_environment()
    global.fs.environment = default_environment
end

-- function to write to stdout
function stdout(input)
    -- write input from cursor location
    global.fs.output.stdout.contents =
        string.sub(global.fs.output.stdout.contents, 1, global.fs.output.stdout.cursor) .. input ..
            string.sub(global.fs.output.stdout.contents, global.fs.output.stdout.cursor + 1)

    -- add length of input to cursor
    global.fs.output.stdout.cursor = global.fs.output.stdout.cursor + string.len(input)
end

function clear_stdout()
    global.fs.output.stdout.contents = ""
    global.fs.output.stdout.cursor = 1
end

function prompt()
    if not global.fs.environment.repl then
        stdout("engineer@nauvisos:~$ ")
    else
        stdout("engineer@nauvisos [REPL]:~$ ")
    end
end

function help()
    stdout("  1.  help - display this help message\n")
    stdout("  2.  clear - clear the terminal\n")
    stdout("  3.  repl - enter the nauvis os repl environment\n")
end

function clear()
    clear_stdout()
end

function repl()
    if not global.fs.environment.repl then
        global.fs.environment.repl = true
        stdout("Entering REPL environment. Type 'exit' to exit.\n")
    end
end

function boot_os()

    -- clear stdout
    clear_stdout()

    -- reset environment
    reset_environment()

    -- write a welcome message to stdout
    stdout("NauvisOS v0.0.1\nWelcome!\nType 'help' for a list of commands.\n")

    stdout("Memory initialized.\n")
    prompt()

end
