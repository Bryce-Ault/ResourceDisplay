# ResourceDisplay

A lightweight World of Warcraft addon that displays compact health and mana bars below your character.

## Features

- Slim health and mana bars anchored below your character at screen center
- Current resource values displayed as text on each bar
- Text turns red when a resource drops below 20%
- Mana bar auto-hides for classes that don't use mana (warriors, rogues, etc.)


## Configuration

All configuration is done via constants at the top of [ResourceDisplay.lua](ResourceDisplay.lua):

| Constant | Default | Description |
|---|---|---|
| `BAR_WIDTH` | 160 | Bar width in pixels |
| `BAR_HEIGHT` | 11 | Bar height in pixels |
| `BAR_SPACING` | 2 | Gap between health and mana bars |
| `BAR_OFFSET_Y` | -145 | Vertical offset from screen center |
| `BG_ALPHA` | 0.4 | Background transparency |
| `BAR_ALPHA` | 0.7 | Bar fill transparency |
| `HEALTH_COLOR` | 0.3, 0.7, 0.3 | Health bar RGB |
| `MANA_COLOR` | 0.3, 0.45, 0.8 | Mana bar RGB |
