class_name PlatformerConfig
extends RefCounted

# Kacheln & Weltgeometrie
const TILE_SIZE: float = 48.0
const LEVEL_HEIGHT_ROWS: int = 14
const PLAYER_WIDTH: float = 38.0
const PLAYER_HEIGHT: float = 44.0

# Kinematik & Physik (Y zeigt in Godot nach unten!)
const GRAVITY: float = 1400.0
const MAX_RUN_SPEED: float = 360.0
const ACCELERATION: float = 2000.0
const FRICTION: float = 800.0
const AIR_CONTROL: float = 0.65
const JUMP_FORCE: float = -650.0
const VARIABLE_JUMP_CUT: float = 0.45

# Game Feel Puffer
const COYOTE_TIME_SEC: float = 0.12
const JUMP_BUFFER_SEC: float = 0.12

# Level-Grenzen & Startpunkt
const START_X: float = 120.0
const START_Y: float = 580.0
const DEATH_Y: float = 800.0
