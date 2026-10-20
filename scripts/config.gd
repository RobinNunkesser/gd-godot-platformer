class_name PlatformerConfig
extends RefCounted

# Kacheln & Weltgeometrie
const TILE_SIZE: float = 48.0
const LEVEL_HEIGHT_ROWS: int = 14
const PLAYER_WIDTH: float = 38.0
const PLAYER_HEIGHT: float = 44.0

# Kinematik & Physik (Y zeigt in Godot nach unten!)
const GRAVITY: float = 1350.0
const MAX_RUN_SPEED: float = 400.0
const ACCELERATION: float = 2200.0
const FRICTION: float = 800.0
const AIR_CONTROL: float = 0.75
# Sprungimpuls: h_max = 770^2 / (2 * 1350) = 219.6 px = 4.58 Blöcke (überwindet 3- und 4-Block Röhren)
const JUMP_FORCE: float = -770.0
const VARIABLE_JUMP_CUT: float = 0.5

# Game Feel Puffer
const COYOTE_TIME_SEC: float = 0.12
const JUMP_BUFFER_SEC: float = 0.12

# Level-Grenzen & Startpunkt
const START_X: float = 120.0
const START_Y: float = 580.0
const DEATH_Y: float = 800.0
