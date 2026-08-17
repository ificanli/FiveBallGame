# Third-party dependencies

| Dependency | Locked version | Source | License | Removal |
|---|---|---|---|---|
| Godot Engine | 4.7.1 stable (`a13da4feb`) | winget `GodotEngine.GodotEngine` | MIT | Uninstall winget package; project files remain readable |
| GdUnit4 | v6.2.0 (`d18770221c2df4a3c991a42fdce7907df40eea75`) | https://github.com/godot-gdunit-labs/gdUnit4 | MIT | Remove `addons/gdUnit4`, disable plugin, remove test runner |
| OpenSpec CLI | 1.9.0 | npm/global tool | See upstream | Remove `.pi` generated commands/skills and `openspec/` only after archiving specs |

Godot MCP, GodotSteam, networking libraries, and analytics are intentionally absent.
