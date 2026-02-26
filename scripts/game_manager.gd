extends Node

const MAIN_MENU_SCENE: String = "res://MainMenu.tscn"
const GAME_SCENE: String = "res://Main.tscn"

func go_main_menu() -> void:
	get_tree().paused = false
	var err: int = get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(GAME_SCENE)

func try_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func pause_game() -> void:
	get_tree().paused = true

func resume_game() -> void:
	get_tree().paused = false

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
