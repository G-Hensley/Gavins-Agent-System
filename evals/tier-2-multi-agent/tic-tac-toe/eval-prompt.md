Build me a tic-tac-toe game with two interfaces: a terminal version and a web UI.

Both interfaces should support two human players taking turns. The web UI should look polished — clean layout, clear indication of whose turn it is, highlighted winning line, and a "Play Again" button after the game ends.

The terminal version should run as a Python script (`python tictactoe.py`) and render the board in ASCII with labeled positions so players know what to type.

The game logic (win detection, turn management, draw detection) should be shared between both interfaces — don't duplicate it.

Write tests for the game logic before implementing it.

Deliverables:
- `tictactoe.py` — terminal interface
- `web/` — React app with the web UI
- `game.py` (or equivalent shared module) — core logic with pytest coverage
- Tests passing before any UI code is written
