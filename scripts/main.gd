# main.gd
extends Control

enum State { PLAYER_CHOOSE, PLAYER_ANSWER, RESOLVE_PLAYER, ENEMY_TURN, UPGRADE, GAME_OVER }
var state: State = State.PLAYER_CHOOSE

@onready var combat := Combat.new()
@onready var math := MathGen.new()
var rng := RandomNumberGenerator.new()
@onready var background: TextureRect = %BackgroundBattle

# Bars
@onready var player_hp_bar: ProgressBar = %PlayerHP
@onready var enemy_hp_bar: ProgressBar = %EnemyHP

# Texts
@onready var player_name_label: Label = %PlayerName
@onready var player_hp_text: Label = %PlayerHPText
@onready var enemy_name_label: Label = %EnemyName
@onready var enemy_hp_text: Label = %EnemyHPText

# Prompt/log
@onready var prompt_label: Label = %PromptLabel
@onready var hint_label: Label = %HintLabel
@onready var log_text: RichTextLabel = %LogText

# Answer row
@onready var answer_row: Control = %AnswerRow
@onready var answer_input: LineEdit = %AnswerInput
@onready var submit_btn: Button = %SubmitBtn
@onready var cancel_btn: Button = %CancelBtn

# Action buttons
@onready var attack_btn: Button = %AttackBtn
@onready var defend_btn: Button = %DefendBtn
@onready var heal_btn: Button = %HealBtn
@onready var special_btn: Button = %SpecialBtn

# Battlers
@onready var player_anim: Battler = %Player
@onready var enemy_anim: Battler = %Enemy

# Game over menu
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var game_over_menu: GameOverMenu = %GameOverMenu

# Characters
var player: Combat.CombatCharacter
var enemy: Combat.CombatCharacter

# Pending action/problem
var pending_action: Combat.ActionType = Combat.ActionType.ATTACK
var pending_problem: Dictionary = {}
var pending_diff: MathGen.Difficulty = MathGen.Difficulty.NORMAL

# Cooldowns (player turns)
var cd_special: int = 0
var cd_heal: int = 0

var bg_list: Array[Texture2D] = [
		preload("res://backgrounds/Airship 1.png"),
		preload("res://backgrounds/Airship 2.png"),
		preload("res://backgrounds/Airship 3.png"),
		preload("res://backgrounds/Baren Falls.png"),
		preload("res://backgrounds/Castle Empire 1.png"),
		preload("res://backgrounds/Castle Empire 2.png"),
		preload("res://backgrounds/Cave 1.png"),
		preload("res://backgrounds/Cave 2.png"),
		preload("res://backgrounds/Cave 3.png"),
		preload("res://backgrounds/Cave 4.png"),
		preload("res://backgrounds/Cave 5.png"),
		preload("res://backgrounds/Coliseum.png"),
		preload("res://backgrounds/Darill's Tomb.png"),
		preload("res://backgrounds/Floating Continent.png"),
		preload("res://backgrounds/Forest 1.png"),
		preload("res://backgrounds/Forest 2.png"),
		preload("res://backgrounds/Imperial Camp.png"),
		preload("res://backgrounds/Inner.png"),
		preload("res://backgrounds/Kefka's Tower 1.png"),
		preload("res://backgrounds/Kefka's Tower 2.png"),
		preload("res://backgrounds/Magitek Factory 1.png"),
		preload("res://backgrounds/Magitek Factory 2.png"),
		preload("res://backgrounds/Minecart.png"),
		preload("res://backgrounds/Mountain.png"),
		preload("res://backgrounds/Owzer' s mansion.png"),
		preload("res://backgrounds/Phantom Train 1.png"),
		preload("res://backgrounds/Phantom Train 2.png"),
		preload("res://backgrounds/Phantom Train 3.png"),
		preload("res://backgrounds/Plains.png"),
		preload("res://backgrounds/Sealed Gate.png"),
		preload("res://backgrounds/Snow.png"),
		preload("res://backgrounds/Stage.png"),
		preload("res://backgrounds/Tower.png"),
		preload("res://backgrounds/Town 1.png"),
		preload("res://backgrounds/Town 2.png"),
		preload("res://backgrounds/Town 3.png"),
		preload("res://backgrounds/Town 4.png"),
		preload("res://backgrounds/Vector.png"),
		preload("res://backgrounds/Veldt.png"),
		preload("res://backgrounds/Wasteland.png")
]
	
# -----------------------------
# Endless enemy roster (10)
# -----------------------------
class EnemyTemplate:
	var name: String
	var hp: int
	var atk: int
	var defense: int
	var heal: int
	var frames: SpriteFrames

	func _init(n: String, _hp: int, _atk: int, _def: int, _heal: int, _frames: SpriteFrames) -> void:
		name = n
		hp = _hp
		atk = _atk
		defense = _def
		heal = _heal
		frames = _frames

var enemies: Array[EnemyTemplate] = []
var enemy_index: int = 0
var cycle: int = 0  # after beating 10 enemies, cycle++ => harder

func _ready() -> void:
	rng.randomize()

	# -----------------------------
	# ✅ SET YOUR SPRITEFRAMES PATHS HERE
	# Create SpriteFrames resources (.tres) for each enemy and put correct paths.
	# Must include animations named: idle, attack, hurt, heal (optional), special (optional)
	# -----------------------------
	var player_frames: SpriteFrames = preload("res://character/slime.tres") as SpriteFrames
	player_anim.set_sprite_frames(player_frames)
	player_anim.reset_home_to_current() # กัน drift หลังเปลี่ยน frames

	var bat_frames: SpriteFrames = preload("res://character/bat.tres") as SpriteFrames
	var leafen_frames: SpriteFrames = preload("res://character/leafen.tres") as SpriteFrames
	#var slime_frames: SpriteFrames = preload("res://enemies/slime.tres")
	#var bat_frames: SpriteFrames = preload("res://enemies/bat_frames.tres")
	#var goblin_frames: SpriteFrames = preload("res://enemies/goblin_frames.tres")
	#var wolf_frames: SpriteFrames = preload("res://enemies/wolf_frames.tres")
	#var skeleton_frames: SpriteFrames = preload("res://enemies/skeleton_frames.tres")
	#var mage_frames: SpriteFrames = preload("res://enemies/mage_frames.tres")
	#var orc_frames: SpriteFrames = preload("res://enemies/orc_frames.tres")
	#var knight_frames: SpriteFrames = preload("res://enemies/knight_frames.tres")
	#var demon_frames: SpriteFrames = preload("res://enemies/demon_frames.tres")
	#var dragon_frames: SpriteFrames = preload("res://enemies/dragon_frames.tres")

	enemies = [
		EnemyTemplate.new("Bat",        75, 1, 0, 0, bat_frames),
		EnemyTemplate.new("Leafen",      80, 1, 1, 0, leafen_frames)
		#EnemyTemplate.new("Bat",        75, 1, 0, 0, bat_frames),
		#EnemyTemplate.new("Goblin",     85, 2, 1, 0, goblin_frames),
		#EnemyTemplate.new("Wolf",       90, 3, 1, 0, wolf_frames),
		#EnemyTemplate.new("Skeleton",   95, 3, 2, 0, skeleton_frames),
		#EnemyTemplate.new("Mage",       90, 2, 1, 2, mage_frames),
		#EnemyTemplate.new("Orc",       110, 4, 2, 0, orc_frames),
		#EnemyTemplate.new("Knight",    120, 4, 3, 0, knight_frames),
		#EnemyTemplate.new("Demon",     130, 5, 2, 2, demon_frames),
		#EnemyTemplate.new("Dragonling",150, 6, 3, 1, dragon_frames),
	]
	
	# Player base stats
	player = Combat.CombatCharacter.new("Hero", 100, 2, 1, 0)

	# Bars
	player_hp_bar.show_percentage = false
	enemy_hp_bar.show_percentage = false

	# Answer UI
	answer_row.visible = false

	_connect_buttons()

	# Force readable colors
	player_name_label.add_theme_color_override("font_color", Color(1,1,1,1))
	player_hp_text.add_theme_color_override("font_color", Color(1,1,1,1))
	enemy_name_label.add_theme_color_override("font_color", Color(1,1,1,1))
	enemy_hp_text.add_theme_color_override("font_color", Color(1,1,1,1))

	player_name_label.text = player.name

	_spawn_enemy()
	_refresh_bars()

	_set_prompt_choose()
	_set_action_buttons_enabled(true)
	_update_cooldown_ui()

	_log("[b]Battle Start![/b] Defeat enemies endlessly. Win -> Upgrade 1 stat.")

# ------------------------------------------------------------
# Wiring
# ------------------------------------------------------------

func _connect_buttons() -> void:
	if not attack_btn.pressed.is_connected(_on_attack_pressed):
		attack_btn.pressed.connect(_on_attack_pressed)
	if not defend_btn.pressed.is_connected(_on_defend_pressed):
		defend_btn.pressed.connect(_on_defend_pressed)
	if not heal_btn.pressed.is_connected(_on_heal_pressed):
		heal_btn.pressed.connect(_on_heal_pressed)
	if not special_btn.pressed.is_connected(_on_special_pressed):
		special_btn.pressed.connect(_on_special_pressed)

	if not submit_btn.pressed.is_connected(_on_submit_pressed):
		submit_btn.pressed.connect(_on_submit_pressed)
	if not cancel_btn.pressed.is_connected(_on_cancel_pressed):
		cancel_btn.pressed.connect(_on_cancel_pressed)

	# Enter to submit
	if not answer_input.text_submitted.is_connected(_on_answer_submitted):
		answer_input.text_submitted.connect(_on_answer_submitted)

func _on_answer_submitted(_text: String) -> void:
	if state == State.PLAYER_ANSWER:
		_on_submit_pressed()

# ------------------------------------------------------------
# UI helpers
# ------------------------------------------------------------

func _log(msg: String) -> void:
	log_text.append_text(msg + "\n")
	log_text.scroll_to_line(max(0, log_text.get_line_count() - 1))

func _set_prompt_choose() -> void:
	prompt_label.text = "Choose your next action."
	hint_label.text = "Solve math to perform actions."

func _refresh_bars() -> void:
	player_hp_bar.max_value = float(player.max_hp)
	player_hp_bar.value = float(player.hp)
	player_hp_bar.tooltip_text = "%d / %d" % [player.hp, player.max_hp]
	player_hp_text.text = "%d / %d" % [player.hp, player.max_hp]

	enemy_hp_bar.max_value = float(enemy.max_hp)
	enemy_hp_bar.value = float(enemy.hp)
	enemy_hp_bar.tooltip_text = "%d / %d" % [enemy.hp, enemy.max_hp]
	enemy_hp_text.text = "%d / %d" % [enemy.hp, enemy.max_hp]

func _set_action_buttons_enabled(enabled: bool) -> void:
	attack_btn.disabled = not enabled
	defend_btn.disabled = not enabled

	if not enabled:
		heal_btn.disabled = true
		special_btn.disabled = true
		return

	heal_btn.disabled = (cd_heal > 0)
	special_btn.disabled = (cd_special > 0)

func _update_cooldown_ui() -> void:
	if cd_heal > 0:
		heal_btn.text = "Heal (CD: %d)" % cd_heal
	else:
		heal_btn.text = "Heal"

	if cd_special > 0:
		special_btn.text = "Special (CD: %d)" % cd_special
	else:
		special_btn.text = "Special"

func _decrement_cooldowns_on_new_player_turn() -> void:
	cd_heal = max(0, cd_heal - 1)
	cd_special = max(0, cd_special - 1)
	_update_cooldown_ui()

func _action_name(action: Combat.ActionType) -> String:
	match action:
		Combat.ActionType.ATTACK: return "Attack"
		Combat.ActionType.DEFEND: return "Defend"
		Combat.ActionType.HEAL: return "Heal"
		Combat.ActionType.SPECIAL: return "Special"
		_: return "Action"

func _diff_for_action(action: Combat.ActionType) -> MathGen.Difficulty:
	match action:
		Combat.ActionType.DEFEND: return MathGen.Difficulty.EASY
		Combat.ActionType.ATTACK: return MathGen.Difficulty.NORMAL
		Combat.ActionType.HEAL:   return MathGen.Difficulty.HARD
		Combat.ActionType.SPECIAL:return MathGen.Difficulty.VERY_HARD
		_: return MathGen.Difficulty.NORMAL

# ------------------------------------------------------------
# Endless spawn + scaling + sprite swap
# ------------------------------------------------------------

func _spawn_enemy() -> void:
	var t: EnemyTemplate = enemies[enemy_index]

	# Scaling per cycle
	var hp_mul: float = 1.0 + float(cycle) * 0.18
	var atk_add: int = cycle * 1
	var def_add: int = cycle * 1
	var heal_add: int = int(floor(float(cycle) * 0.5))

	var mhp: int = int(round(float(t.hp) * hp_mul))
	var atk: int = t.atk + atk_add
	var defense: int = t.defense + def_add
	var heal: int = t.heal + heal_add

	enemy = Combat.CombatCharacter.new(t.name, mhp, atk, defense, heal)
	_randomize_background()
	
	# ✅ swap enemy visuals
	if t.frames != null:
		enemy_anim.set_sprite_frames(t.frames)

	enemy_name_label.text = "%s  [Lv : %d]" % [enemy.name, cycle + 1]

func _advance_enemy() -> void:
	enemy_index += 1
	if enemy_index >= enemies.size():
		enemy_index = 0
		cycle += 1
		_log("[color=yellow][b]Cycle Up! Enemies are stronger now.[/b][/color]")

	_spawn_enemy()
	_refresh_bars()

# ------------------------------------------------------------
# Action selection
# ------------------------------------------------------------

func _on_attack_pressed() -> void:
	if state == State.UPGRADE:
		_apply_upgrade("ATK")
		return
	_choose_action(Combat.ActionType.ATTACK)

func _on_defend_pressed() -> void:
	if state == State.UPGRADE:
		_apply_upgrade("DEF")
		return
	_choose_action(Combat.ActionType.DEFEND)

func _on_heal_pressed() -> void:
	if state == State.UPGRADE:
		_apply_upgrade("HP")
		return
	if cd_heal > 0:
		return
	_choose_action(Combat.ActionType.HEAL)

func _on_special_pressed() -> void:
	if state == State.UPGRADE:
		_apply_upgrade("HEAL")
		return
	if cd_special > 0:
		return
	_choose_action(Combat.ActionType.SPECIAL)

func _choose_action(action: Combat.ActionType) -> void:
	if state != State.PLAYER_CHOOSE:
		return

	pending_action = action
	pending_diff = _diff_for_action(action)
	pending_problem = math.make_problem(pending_diff)

	state = State.PLAYER_ANSWER
	_set_action_buttons_enabled(false)

	answer_row.visible = true
	answer_input.text = ""
	answer_input.grab_focus()

	var a_name := _action_name(action)
	prompt_label.text = "%s requires solving:" % a_name
	hint_label.text = "Difficulty: %s | Topic: %s" % [
		String(pending_problem.get("diff", "")),
		String(pending_problem.get("topic", ""))
	]

	_log("[i]You chose %s.[/i]" % a_name)
	_log("[b]Problem:[/b] " + String(pending_problem.get("q", "")))

# ------------------------------------------------------------
# Submit/Cancel
# ------------------------------------------------------------

func _on_submit_pressed() -> void:
	if state != State.PLAYER_ANSWER:
		return

	var ok := math.check_answer(answer_input.text, pending_problem)
	answer_row.visible = false
	await _resolve_player(ok)

func _on_cancel_pressed() -> void:
	if state != State.PLAYER_ANSWER:
		return

	answer_row.visible = false
	state = State.PLAYER_CHOOSE
	_set_prompt_choose()
	_set_action_buttons_enabled(true)
	_update_cooldown_ui()

# ------------------------------------------------------------
# Turn resolution
# ------------------------------------------------------------

func _resolve_player(correct: bool) -> void:
	state = State.RESOLVE_PLAYER

	var diff_label := String(pending_problem.get("diff", "Normal"))
	var res := combat.apply_player_action(player, enemy, pending_action, correct, diff_label)

	if bool(res.get("success", false)):
		if pending_action == Combat.ActionType.SPECIAL:
			cd_special = 3
		elif pending_action == Combat.ActionType.HEAL:
			cd_heal = 2
		_update_cooldown_ui()

		await _play_player_success_animations(pending_action)
		_log("✅ Correct! " + String(res.get("log", "")))
	else:
		_log("❌ Wrong! " + String(res.get("log", "")))

	_refresh_bars()

	# Enemy dead => Upgrade => Next enemy
	if enemy.is_dead():
		await _on_enemy_defeated()
		return

	state = State.ENEMY_TURN
	await _enemy_turn()

func _play_player_success_animations(action: Combat.ActionType) -> void:
	match action:
		Combat.ActionType.ATTACK:
			await player_anim.play_attack(enemy_anim.global_position)
			await enemy_anim.play_hurt()
		Combat.ActionType.SPECIAL:
			await player_anim.play_special(enemy_anim.global_position)
			await enemy_anim.play_hurt()
		Combat.ActionType.HEAL:
			await player_anim.play_heal()
		Combat.ActionType.DEFEND:
			pass

func _enemy_turn() -> void:
	var res := combat.enemy_turn(player, enemy, rng)

	if int(res.get("heal", 0)) > 0:
		await enemy_anim.play_heal()
	else:
		await enemy_anim.play_attack(player_anim.global_position)
		await player_anim.play_hurt()

	_log(String(res.get("log", "")))
	_refresh_bars()

	if player.is_dead():
		state = State.GAME_OVER
		_log("[color=red][b]You lost![/b][/color]")
		_set_action_buttons_enabled(false)
		answer_row.visible = false
		return

	_decrement_cooldowns_on_new_player_turn()

	state = State.PLAYER_CHOOSE
	_set_prompt_choose()
	_set_action_buttons_enabled(true)
	_update_cooldown_ui()

# ------------------------------------------------------------
# Upgrade system (reuse the same 4 buttons)
# ------------------------------------------------------------

func _on_enemy_defeated() -> void:
	state = State.UPGRADE
	_set_action_buttons_enabled(false)
	answer_row.visible = false

	_log("[color=lime][b]Enemy defeated![/b][/color]")
	_log("[b]Choose an upgrade:[/b]")
	_log("Attack: +1 ATK | Defend: +1 DEF | Heal: +8 MaxHP | Special: +1 HealPower")

	attack_btn.text = "UP ATK +1"
	defend_btn.text = "UP DEF +1"
	heal_btn.text = "UP MaxHP +8"
	special_btn.text = "UP Heal +1"

	attack_btn.disabled = false
	defend_btn.disabled = false
	heal_btn.disabled = false
	special_btn.disabled = false

	prompt_label.text = "Upgrade time!"
	hint_label.text = "Pick one upgrade, then next enemy starts."

func _apply_upgrade(kind: String) -> void:
	if kind == "ATK":
		player.atk += 1
		_log("⭐ Player ATK +1  (ATK=%d)" % player.atk)
	elif kind == "DEF":
		player.defense += 1
		_log("⭐ Player DEF +1  (DEF=%d)" % player.defense)
	elif kind == "HP":
		player.max_hp += 8
		player.hp += 8
		player.clamp_hp()
		_log("⭐ Player MaxHP +8  (HP=%d/%d)" % [player.hp, player.max_hp])
	elif kind == "HEAL":
		player.heal_power += 1
		_log("⭐ Player HealPower +1  (Heal=%d)" % player.heal_power)

	_refresh_bars()

	# restore button labels back to battle actions
	attack_btn.text = "Attack"
	defend_btn.text = "Defend"
	_update_cooldown_ui() # will set Heal/Special texts properly

	# next enemy
	_advance_enemy()

	state = State.PLAYER_CHOOSE
	_set_prompt_choose()
	_set_action_buttons_enabled(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and state != State.GAME_OVER:
		# ถ้าเมนูโชว์อยู่ -> ปิด, ถ้าไม่โชว์ -> เปิด
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()
			
func _check_game_over() -> bool:
	if player.hp <= 0:
		state = State.GAME_OVER
		_log("[color=red][b]You lost![/b][/color]")
		_set_action_buttons_enabled(false)
		answer_row.visible = false
		game_over_menu.show_result(false)
		return true

	if enemy.hp <= 0:
		state = State.GAME_OVER
		_log("[color=lime][b]You win![/b][/color]")
		_set_action_buttons_enabled(false)
		answer_row.visible = false
		game_over_menu.show_result(true)
		return true

	return false

func _randomize_background() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var index: int = rng.randi_range(0, bg_list.size() - 1)
	background.texture = bg_list[index]
