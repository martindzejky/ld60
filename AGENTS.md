# Project

Read `README.md` first.

This is a Godot 4.7.2 game for the Ludum Dare #60 compo. Keep changes small and simple.

Every push checks the Web export. Tag pushes also deploy to itch.io.

# Godot MCP

Use the `godot` MCP server from `.codex/config.toml`. It runs `godot-mcp-runtime` through `npx`. You need Node.js and Godot on `PATH`. No addon needed.

1. Call `check_project` with the repo's absolute path as `projectPath`.
2. Call `run_project` with the same path.
3. Inspect a `take_screenshot` image and check `get_debug_output` for errors. Test changed interactions with `simulate_input`.
4. Call `stop_project` when done.

Temporary bridge files and screenshots go in `.mcp/`, which Git ignores.
