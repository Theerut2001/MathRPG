extends Control
class_name PauseMenu

@onready var resume_btn: Button = %ResumeBtn
@onready var try_btn: Button = %TryAgainBtn
@onready var main_btn: Button = %MainMenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	resume_btn.pressed.connect(_on_resume)
	try_btn.pressed.connect(_on_try_again)
	main_btn.pressed.connect(_on_main_menu)

	hide()

func open() -> void:
	show()
	GameManager.pause_game()

func close() -> void:
	hide()
	GameManager.resume_game()

func _on_resume() -> void:
	close()

func _on_try_again() -> void:
	GameManager.try_again()

func _on_main_menu() -> void:
	GameManager.go_main_menu()
