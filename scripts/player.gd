class_name PlatformerPlayer
extends CharacterBody2D

const PlatformerConfig = preload("res://scripts/config.gd")

signal block_hit_from_below(block: StaticBody2D)
signal player_jumped

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_facing_right: bool = true

@onready var visual_body: ColorRect = get_node_or_null("Visual/Body")
@onready var visual_visor: ColorRect = get_node_or_null("Visual/Visor")

func _ready() -> void:
	reset_position()

func reset_position(pos: Vector2 = Vector2(PlatformerConfig.START_X, PlatformerConfig.START_Y)) -> void:
	position = pos
	velocity = Vector2.ZERO
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	is_facing_right = true
	_update_visor()

func update_kinematics(delta: float, input_left: bool, input_right: bool, input_jump_pressed: bool, input_jump_held: bool) -> void:
	# 1. Timer aktualisieren
	if is_on_floor():
		coyote_timer = PlatformerConfig.COYOTE_TIME_SEC
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	if input_jump_pressed:
		jump_buffer_timer = PlatformerConfig.JUMP_BUFFER_SEC
	else:
		jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)

	# 2. Horizontale Bewegung & Reibung
	var accel := PlatformerConfig.ACCELERATION if is_on_floor() else PlatformerConfig.ACCELERATION * PlatformerConfig.AIR_CONTROL
	if input_right and not input_left:
		velocity.x = minf(PlatformerConfig.MAX_RUN_SPEED, velocity.x + accel * delta)
		is_facing_right = true
		_update_visor()
	elif input_left and not input_right:
		velocity.x = maxf(-PlatformerConfig.MAX_RUN_SPEED, velocity.x - accel * delta)
		is_facing_right = false
		_update_visor()
	else:
		# Abbremsen
		if velocity.x > 0.0:
			velocity.x = maxf(0.0, velocity.x - PlatformerConfig.FRICTION * delta * 2.0)
		elif velocity.x < 0.0:
			velocity.x = minf(0.0, velocity.x + PlatformerConfig.FRICTION * delta * 2.0)

	# 3. Sprung-Ausführung (Coyote Time + Buffer)
	var can_jump := is_on_floor() or coyote_timer > 0.0
	if can_jump and jump_buffer_timer > 0.0:
		velocity.y = PlatformerConfig.JUMP_FORCE
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		player_jumped.emit()

	# 4. Variable Sprunghöhe: Loslassen kappt den Sprung
	if not input_jump_held and velocity.y < 0.0:
		velocity.y *= PlatformerConfig.VARIABLE_JUMP_CUT

	# 5. Gravitation
	velocity.y += PlatformerConfig.GRAVITY * delta

	# 6. Godot Engine Physics-Integration
	if is_inside_tree() and get_world_2d() and get_world_2d().space.is_valid():
		move_and_slide()

		# 7. Kopfstöße gegen Blöcke an der Decke detektieren
		if is_on_ceiling():
			for i in range(get_slide_collision_count()):
				var collision := get_slide_collision(i)
				var collider := collision.get_collider()
				if collider is StaticBody2D and collider.is_in_group("question_blocks"):
					block_hit_from_below.emit(collider)
	else:
		position += velocity * delta

func _update_visor() -> void:
	if visual_visor:
		if is_facing_right:
			visual_visor.position.x = 8.0
		else:
			visual_visor.position.x = -16.0
