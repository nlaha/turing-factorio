-- create computer GUI
commands.add_command("tf_show", nil, function(command)
    local player = game.get_player(command.player_index)
    local screen_element = player.gui.screen

    boot_os()

    -- create outer frame for the computer
    local outer_frame = screen_element.add {
        type = "frame",
        name = "tf_computer_frame_outer",
        caption = {"tf.global_menu_caption"},
        style = "machine_frame"
    }
    outer_frame.auto_center = true

    -- close button
    local close_button = outer_frame.add {
        type = "sprite-button",
        name = "tf_close_button",
        style = "close_button",
        sprite = "utility/close_white"
    }

    -- create main frame for the computer terminal
    local computer_frame = outer_frame.add {
        type = "frame",
        name = "tf_computer_frame",
        style = "tf_computer_frame"
    }

    -- create text for the computer terminal
    local text = computer_frame.add {
        type = "text-box",
        name = "tf_terminal_text",
        text = global.fs.output.stdout.contents,
        style = "tf_terminal_text"
    }

end)
