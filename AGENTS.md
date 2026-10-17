# Project

Read `README.md` first.

This is a Godot game for the Ludum Dare #60 compo. The theme is "Old Tech".

## Jam rules

- Keep it super simple. Prioritize a fun, playable game and finishing on time.
- Hacks, hardcoded values, and quick solutions are welcome.
- Skip architecture, abstractions, design patterns, and performance work unless needed to make the game work.
- Keep changes small and focused on the current task.
- Write readable code. Code comments are welcome, keep them to the point. Empty lines for readability.
- When useful, reference the other public game repos at https://github.com/martindzejky, especially previous games and jam entries, for reusable scripts and examples. Check local clones first.
- Always work locally on the master branch, commit to it directly. No PRs for simplicity and speed.

## Build and releases

- Keep the build pipeline working: `.github/workflows/web-export.yml` builds the Web export on every push and automatically deploys tag pushes to itch.io.
- Before creating a release tag, set `application/config/version` in `project.godot` to exactly match the tag name, and include that change in the tagged commit.
- Verify the Web export with `godot --headless --export-release Web dist/web/index.html` (create `dist/web` first).

## Subagents

Utilize subagents heavily for parallel work. The main agent is the coordinator. Keep the scope and effort proportionate to a game jam. Ideas for useful dedicated subagent specialists:

- Code reviewer, reviewing code changes as the game evolves
- Playtester, playing the actual game using the Godot MCP
- Researcher, searching online for documentation, best practices, answers, inspiration

The user and the main agent are the "core development team" working on the game and its code together. The main agent then dispatches subagents for parallel work at meaningful checkpoints or pauses.

## Playtesting

Use the `godot` MCP server from `.codex/config.toml` (Node.js and Godot must be on `PATH`). For gameplay changes, call `check_project` and `run_project` with the repo's absolute path as `projectPath`, inspect `take_screenshot` and `get_debug_output`, test interactions with `simulate_input`, then call `stop_project`. Temporary files go in `.mcp/`, which Git ignores.

Playtesting should be done by a dedicated subagent. Multiple cheap subagents could be launched in parallel to test different strategies or personalities or skill levels.
