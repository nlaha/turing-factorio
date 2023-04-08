local styles = data.raw["gui-style"].default

require 'prototypes/fonts'
require 'prototypes/terminal'

local terminal_frame = {
    base = {
        type = "composition",
        center = {
            filename = "__turing-factorio__/graphics/terminal_frame_bg.png",
            name = "terminal_text_bg",
            type = "sprite",
            width = 942,
            height = 530
        }
    }
}

styles["tf_computer_frame"] = {
    type = "frame_style",
    parent = "subpanel_inset_frame_packed",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    left_margin = 10,
    width = 942,
    height = 530,
    graphical_set = terminal_frame
}

styles["tf_terminal_text"] = {
    type = "textbox_style",
    parent = "notice_textbox",
    top_margin = 106,
    left_margin = 113,
    width = 420,
    height = 280,
    font = "vt323",
    font_size = 26,
    active_background = {}
}
