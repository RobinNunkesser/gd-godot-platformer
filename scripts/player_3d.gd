class_name PlatformerPlayer3D
extends CharacterBody3D

const PlatformerConfig3D = preload("res://scripts/config_3d.gd")

signal block_hit_from_below(block: StaticBody3D)
signal player_jumped

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_facing_right: bool = true

@onready var visual_mesh: Node3D = get_node_or_null("Visual")

func _ready() -> void:
	# 2.5D Achsen-Sperre: Keine Bewegung auf Z!
	axis_lock_linear_z = true
	reset_position()

func reset_position(pos: Vector3 = Vector3(PlatformerConfig3D.START_X, PlatformerConfig3D.START_Y, 0.0)) -> void:
	position = pos
	velocity = Vector3.ZERO
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	is_facing_right = true
	_update_rotation()

func update_kinematics(delta: float, input_left: bool, input_right: bool, input_jump_pressed: bool, input_jump_held: bool) -> void:
	# 1. Timer
	if is_on_floor():
		coyote_timer = PlatformerConfig3D.COYOTE_TIME_SEC
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	if input_jump_pressed:
		jump_buffer_timer = PlatformerConfig3D.JUMP_BUFFER_SEC
	else:
		jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)

	# 2. Horizontale Bewegung & Reibung
	var accel := PlatformerConfig3D.ACCELERATION if is_on_floor() else PlatformerConfig3D.ACCELERATION * PlatformerConfig3D.AIR_CONTROL
	if input_right and not input_left:
		velocity.x = minf(PlatformerConfig3D.MAX_RUN_SPEED, velocity.x + accel * delta)
		is_facing_right = true
		_update_rotation()
	elif input_left and not input_right:
		velocity.x = maxf(-PlatformerConfig3D.MAX_RUN_SPEED, velocity.x - accel * delta)
		is_facing_right = false
		_update_rotation()
	else:
		# Abbremsen
		if velocity.x > 0.0:
			velocity.x = maxf(0.0, velocity.x - PlatformerConfig3D.FRICTION * delta * PlatformerConfig3D.MAX_RUN_SPEED)
		elif velocity.x < 0.0:
			velocity.x = minf(0.0, velocity.x + PlatformerConfig3D.FRICTION * delta * PlatformerConfig3D.MAX_RUN_SPEED)

	# 3. Sprung-Ausführung (+Y ist in 3D oben!)
	var can_jump := is_on_floor() or coyote_timer > 0.0
	if can_jump and jump_buffer_timer > 0.0:
		velocity.y = PlatformerConfig3D.JUMP_FORCE
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		player_jumped.emit()

	# 4. Variable Sprunghöhe
	if not input_jump_held and velocity.y > 0.0:
		velocity.y *= PlatformerConfig3D.VARIABLE_JUMP_CUT

	# 5. Gravitation
	velocity.y -= PlatformerConfig3D.GRAVITY * delta

	# Z strikt auf 0 halten
	velocity.z = 0.0

	# 6. 3D Engine Physics Move
	if is_inside_tree() and get_world_3d() and get_world_3d().space.is_valid():
		move_and_slide()

		# 7. Kopfstoß an Decke
		if is_on_ceiling():
			for i in range(get_slide_collision_count()):
				var collision := get_slide_collision(i)
				var collider := collision.get_collider()
				if collider is StaticBody3D and collider.is_in_group("question_blocks_3d"):
					block_hit_from_below.emit(collider)
	else:
		position += velocity * delta

func _update_rotation() -> void:
	if visual_mesh:
		visual_mesh.rotation.y = 0.0 if is_facing_right else PI
