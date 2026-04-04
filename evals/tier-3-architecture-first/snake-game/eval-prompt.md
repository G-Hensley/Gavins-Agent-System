Build a multiplayer Snake game with a persistent leaderboard.

The game should have three parts:

1. **Game server** — WebSocket server (Node.js or Python) that manages game rooms. Each room runs a single Snake game loop at a fixed tick rate. The server validates all moves server-side so clients cannot cheat. When a player dies, their score is submitted to the leaderboard.

2. **Web frontend** — Browser client that connects to the game server via WebSocket. Renders the game board on a `<canvas>` element. Accepts keyboard input and sends moves to the server. Displays the current score and a live list of active players in the room.

3. **Leaderboard** — Persists top scores with player name, score, and timestamp. Exposed via a REST endpoint that the frontend polls on the game-over screen. Storage can be SQLite or an in-memory store backed to a JSON file — just make it survive a server restart.

Players should be able to open the game in a browser, enter a name, join a room, play, and see their score appear on the leaderboard when they finish.

Write tests for the game logic (collision detection, food spawning, score calculation) and for the leaderboard API. The game server and frontend can be in separate directories within the project.
