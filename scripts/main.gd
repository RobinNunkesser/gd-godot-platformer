class_name MainScene
extends Node2D

const PlatformerConfig = preload("res://scripts/config.gd")
const PlatformerStateManager = preload("res://scripts/state_manager.gd")
const TileMapLoader = preload("res://scripts/tilemap_loader.gd")
const PlatformerPlayer = preload("res://scripts/player.gd")

@onready var tilemap_loader: TileMapLoader = $TileMapLoader
@onready var player: PlatformerPlayer = $Player
@onready var camera: Camera2D = $Camera2D

# UI
@onready var lbl_score: Label = $CanvasLayer/HUD/ScoreContainer/ScoreValue
@onready var lbl_coins: Label = $CanvasLayer/HUD/CoinsContainer/CoinsValue
@onready var lbl_highscore: Label = $CanvasLayer/HUD/TopContainer/TopValue

@onready var overlay_start: Control = $CanvasLayer/StartOverlay
@onready var overlay_pause: Control = $CanvasLayer/PauseOverlay
@onready var overlay_gameover: Control = $CanvasLayer/GameOverOverlay
@onready var overlay_victory: Control = $CanvasLayer/VictoryOverlay

@onready var gameover_score: Label = $CanvasLayer/GameOverOverlay/Card/ScoreLabel
@onready var victory_score: Label = $CanvasLayer/VictoryOverlay/Card/ScoreLabel

var state_manager: PlatformerStateManager

func _ready() -> void:
	state_manager = PlatformerStateManager.new()
	state_manager.score_changed.connect(_on_score_changed)
	state_manager.coins_changed.connect(_on_coins_changed)
	state_manager.state_changed.connect(_on_state_changed)

	var level_path := "res://levels/level-1.txt"
	if not FileAccess.file_exists(level_path) and FileAccess.file_exists("res://levels/mario-1-1.txt"):
		level_path = "res://levels/mario-1-1.txt"
	tilemap_loader.load_level_from_file(level_path)
	tilemap_loader.coin_collected.connect(_on_coin_collected)
	tilemap_loader.goal_reached.connect(_on_goal_reached)

	player.block_hit_from_below.connect(_on_block_hit)

	_bind_ui_buttons()
	_update_hud()

	# Start in READY State
	_show_overlay(overlay_start)

func _bind_ui_buttons() -> void:
	$CanvasLayer/StartOverlay/Card/StartButton.pressed.connect(start_game)
	$CanvasLayer/PauseOverlay/Card/ResumeButton.pressed.connect(toggle_pause)
	$CanvasLayer/GameOverOverlay/Card/RestartButton.pressed.connect(restart_game)
	$CanvasLayer/VictoryOverlay/Card/RestartButton.pressed.connect(restart_game)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_pressed("restart"):
		restart_game()

	if state_manager.current_state == PlatformerStateManager.State.PLAYING:
		var in_left := Input.is_action_pressed("move_left")
		var in_right := Input.is_action_pressed("move_right")
		var in_jump_pressed := Input.is_action_just_pressed("jump")
		var in_jump_held := Input.is_action_pressed("jump")

		player.update_kinematics(delta, in_left, in_right, in_jump_pressed, in_jump_held)

		# Fortschrittspunkte (Distanz nach rechts)
		var dist_score := int(player.position.x / 10.0)
		state_manager.add_progress_distance(dist_score)

		# Absturz in Abgrund prüfen
		if player.position.y > PlatformerConfig.DEATH_Y:
			state_manager.fall()

		# Kamera-Nachführung (sanftes Lerp)
		var target_cam_x := player.position.x + 120.0
		camera.position.x = lerp(camera.position.x, target_cam_x, 6.0 * delta)
		camera.position.y = 360.0 # Vertikal mittig stabilisiert

func start_game() -> void:
	_hide_all_overlays()
	state_manager.start()

func toggle_pause() -> void:
	state_manager.toggle_pause()

func restart_game() -> void:
	_hide_all_overlays()
	player.reset_position()
	camera.position.x = PlatformerConfig.START_X + 120.0
	state_manager.reset()
	state_manager.start()

func _on_block_hit(block: StaticBody2D) -> void:
	tilemap_loader.hit_block(block)

func _on_coin_collected(_col: int, _row: int) -> void:
	state_manager.add_coin()

func _on_goal_reached() -> void:
	state_manager.win()

func _on_score_changed(_score: int) -> void:
	_update_hud()

func _on_coins_changed(_coins: int) -> void:
	_update_hud()

func _on_state_changed(new_state: String) -> void:
	match new_state:
		"PLAYING":
			_hide_all_overlays()
		"PAUSED":
			_show_overlay(overlay_pause)
		"FALLEN":
			gameover_score.text = "SCORE: " + str(state_manager.score)
			_show_overlay(overlay_gameover)
		"VICTORY":
			victory_score.text = "FINAL SCORE: " + str(state_manager.score)
			_show_overlay(overlay_victory)
		"READY":
			_show_overlay(overlay_start)

func _update_hud() -> void:
	if lbl_score:
		lbl_score.text = "%06d" % state_manager.score
	if lbl_coins:
		lbl_coins.text = "×%02d" % state_manager.coins
	if lbl_highscore:
		lbl_highscore.text = "%06d" % state_manager.highscore

func _hide_all_overlays() -> void:
	overlay_start.visible = false
	overlay_pause.visible = false
	overlay_gameover.visible = false
	overlay_victory.visible = false

func _show_overlay(overlay: Control) -> void:
	_hide_all_overlays()
	overlay.visible = true
