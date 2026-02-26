extends Control
class_name GameOverMenu

@onready var result_label: Label = %ResultLabel
@onready var try_btn: Button = %TryAgainBtn
@onready var main_btn: Button = %MainMenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	try_btn.pressed.connect(_on_try_again)
	main_btn.pressed.connect(_on_main_menu)
	hide()

func show_result(win: bool) -> void:
	result_label.text = "You Win!" if win else "You Lost!"
	show()
	GameManager.pause_game()

func _on_try_again() -> void:
	GameManager.try_again()

func _on_main_menu() -> void:
	GameManager.go_main_menu()
