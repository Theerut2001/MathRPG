extends Control

@onready var start_btn: Button = %StartBtn
@onready var quit_btn: Button = %QuitBtn

func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	quit_btn.pressed.connect(_on_quit)

func _on_start() -> void:
	GameManager.start_game()

func _on_quit() -> void:
	get_tree().quit()
