extends SceneTree

const PlatformerConfig = preload("res://scripts/config.gd")
const PlatformerStateManager = preload("res://scripts/state_manager.gd")
const TileMapLoader = preload("res://scripts/tilemap_loader.gd")
const PlatformerPlayer = preload("res://scripts/player.gd")

func _init() -> void:
	print("--- Running Headless Godot 4 Unit & Gameplay Tests ---")
	var success := true

	# Test 1: PlatformerConfig
	print("[1/4] Testing PlatformerConfig...")
	if PlatformerConfig.TILE_SIZE <= 0 or PlatformerConfig.GRAVITY <= 0 or PlatformerConfig.JUMP_FORCE >= 0:
		push_error("Config constants invalid!")
		success = false
	else:
		print("  -> Config constants OK.")

	# Test 2: PlatformerStateManager
	print("[2/4] Testing PlatformerStateManager...")
	var sm = PlatformerStateManager.new()
	sm.reset()
	if sm.get_state_string() != "READY":
		push_error("StateManager did not start in READY!")
		success = false
	sm.start()
	if sm.get_state_string() != "PLAYING":
		push_error("StateManager did not transition to PLAYING!")
		success = false
	sm.add_coin()
	if sm.coins != 1 or sm.score != 100:
		push_error("add_coin failed to update stats!")
		success = false
	sm.win()
	if sm.get_state_string() != "VICTORY":
		push_error("StateManager did not transition to VICTORY!")
		success = false
	print("  -> StateManager OK.")

	# Test 3: TileMapLoader Level Parsing
	print("[3/4] Testing TileMapLoader on VGLC World 1-1...")
	var loader = TileMapLoader.new()
	root.add_child(loader)
	var loaded: bool = loader.load_level_from_file("res://levels/mario-1-1.txt")
	if not loaded:
		push_error("Failed to load levels/mario-1-1.txt!")
		success = false
	elif loader.level_height_rows != 14 or loader.level_width_cols < 200:
		push_error("Level dimensions mismatch: %d rows, %d cols" % [loader.level_height_rows, loader.level_width_cols])
		success = false
	elif loader.question_blocks.size() == 0:
		push_error("No question blocks parsed!")
		success = false
	else:
		print("  -> TileMapLoader parsed %d rows x %d cols (%d question blocks) OK." % [
			loader.level_height_rows,
			loader.level_width_cols,
			loader.question_blocks.size()
		])
	loader.queue_free()

	# Test 4: Player Kinematics Simulation
	print("[4/4] Testing Player Kinematics Simulation...")
	var player_scene = preload("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	player.reset_position(Vector2(100.0, 500.0))

	# Run 5 frames moving right
	for i in range(5):
		player.update_kinematics(0.016, false, true, false, false)
	if player.velocity.x <= 0:
		push_error("Player did not accelerate right!")
		success = false

	# Test jump impulse with coyote timer active
	player.coyote_timer = PlatformerConfig.COYOTE_TIME_SEC
	player.update_kinematics(0.016, false, false, true, true)
	if player.velocity.y >= 0:
		push_error("Player did not receive jump impulse! velocity.y = " + str(player.velocity.y))
		success = false
	else:
		print("  -> Player kinematics & jump impulse OK (velocity.y = %f)." % player.velocity.y)
	player.queue_free()

	if success:
		print("=== ALL GODOT 4 TESTS PASSED SUCCESSFULLY! ===")
		quit(0)
	else:
		push_error("=== TESTS FAILED! ===")
		quit(1)
