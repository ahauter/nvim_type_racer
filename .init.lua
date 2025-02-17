local game_window = require("gamer_buffer")

game_window.MakeWindow()
assert(game_window.IsWindow(), "Window not created successfully")
game_window.MakeRandomCodeBuffer()
