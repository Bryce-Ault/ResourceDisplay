# ResourceDisplay

A lightweight World of Warcraft addon that displays compact health and mana bars below your character.

## Features

- Slim health and mana bars anchored below your character at screen center
- Current resource values displayed as text on each bar
- Text turns red when a resource drops below 20%
- Mana bar auto-hides for classes that don't use mana (warriors, rogues, etc.)
- **MP5 tick spark** — a white line sweeps left to right across the mana bar on the 2-second server tick cycle, syncing automatically when a regen tick is detected
- **Drink tick spark** — a light-blue line sweeps the mana bar while drinking, tracking drink regen ticks independently


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
| `TICK_INTERVAL` | 2.0 | MP5 regen tick interval (seconds) |
| `DRINK_TICK_INTERVAL` | 2.0 | Drink tick interval (seconds) |
| `TICK_SPARK_COLOR` | 1, 1, 1, 0.7 | Regen tick spark RGBA |
| `DRINK_SPARK_COLOR` | 0.4, 0.8, 1, 0.8 | Drink tick spark RGBA |
