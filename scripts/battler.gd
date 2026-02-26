# battler.gd
extends Node2D
class_name Battler

@export_group("Dash")
@export var run_in_time: float = 0.15
@export var run_back_time: float = 0.18
@export var post_anim_pause: float = 0.05

@export_group("Hurt Feedback")
@export var hurt_shake_px: float = 6.0
@export var hurt_shake_time: float = 0.18

@export_group("Flash")
@export var flash_hurt_color: Color = Color(1.0, 0.35, 0.35, 1.0)
@export var flash_heal_color: Color = Color(0.40, 1.0, 0.60, 1.0)
@export var flash_time: float = 0.14

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D

# LOCAL space only (prevents drift)
var _home_pos: Vector2

var _rng := RandomNumberGenerator.new()
var _move_tw: Tween
var _flash_tw: Tween
var _shake_tw: Tween

func _ready() -> void:
	_rng.randomize()
	# If under Control/Container, layout finalizes after a frame
	await get_tree().process_frame
	_home_pos = position
	play_idle()

func reset_home_to_current() -> void:
	_home_pos = position

func set_sprite_frames(frames: SpriteFrames) -> void:
	# Swap animation set (enemy changes)
	if spr == null:
		return
	spr.sprite_frames = frames
	play_idle()

func play_idle() -> void:
	_play_if_exists("idle")

# ------------------------------------------------------------
# Public Actions (await-safe)
# ------------------------------------------------------------

func play_attack(target_global_pos: Vector2) -> void:
	await _dash_and_play_anim(target_global_pos, "attack")

func play_special(target_global_pos: Vector2) -> void:
	await _dash_and_play_anim(target_global_pos, "special", "attack")

func play_hurt() -> void:
	_flash(flash_hurt_color, flash_time)
	_shake(hurt_shake_px, hurt_shake_time)

	if _has_anim("hurt"):
		spr.play("hurt")
		await spr.animation_finished
	else:
		await _wait(0.12)

	play_idle()

func play_heal() -> void:
	_flash(flash_heal_color, flash_time)

	if _has_anim("heal"):
		spr.play("heal")
		await spr.animation_finished
	else:
		await _wait(0.12)

	play_idle()

# ------------------------------------------------------------
# Internals
# ------------------------------------------------------------

func _dash_and_play_anim(target_global_pos: Vector2, anim_name: String, fallback_anim: String = "") -> void:
	# Convert global target -> local target relative to parent
	var target_local: Vector2 = target_global_pos
	var parent_ci := get_parent() as CanvasItem
	if parent_ci != null:
		target_local = parent_ci.to_local(target_global_pos)

	# Prevent tween stacking
	if _move_tw and _move_tw.is_valid():
		_move_tw.kill()

	# Move in (LOCAL)
	_move_tw = create_tween()
	_move_tw.tween_property(self, "position", target_local, run_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _move_tw.finished

	# Choose animation
	var chosen := anim_name
	if not _has_anim(chosen) and not fallback_anim.is_empty():
		chosen = fallback_anim

	# Play animation (or small wait)
	if _has_anim(chosen):
		spr.play(chosen)
		await spr.animation_finished
	else:
		await _wait(0.18)

	if post_anim_pause > 0.0:
		await _wait(post_anim_pause)

	# Move back (LOCAL)
	if _move_tw and _move_tw.is_valid():
		_move_tw.kill()

	_move_tw = create_tween()
	_move_tw.tween_property(self, "position", _home_pos, run_back_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _move_tw.finished

	play_idle()

func _play_if_exists(name: String) -> void:
	if _has_anim(name):
		spr.play(name)

func _has_anim(name: String) -> bool:
	return spr != null and spr.sprite_frames != null and spr.sprite_frames.has_animation(name)

func _wait(sec: float) -> void:
	if sec <= 0.0:
		return
	await get_tree().create_timer(sec).timeout

func _flash(c: Color, dur: float) -> void:
	if spr == null or dur <= 0.0:
		return
	if _flash_tw and _flash_tw.is_valid():
		_flash_tw.kill()

	var orig := spr.modulate
	spr.modulate = c

	_flash_tw = create_tween()
	_flash_tw.tween_property(spr, "modulate", orig, dur)

func _shake(px: float, dur: float) -> void:
	if dur <= 0.0 or px <= 0.0:
		return
	if _shake_tw and _shake_tw.is_valid():
		_shake_tw.kill()

	var start := position
	var steps := 8

	_shake_tw = create_tween()
	for i in range(steps):
		var off := Vector2(_rng.randf_range(-px, px), _rng.randf_range(-px, px))
		_shake_tw.tween_property(self, "position", start + off, dur / float(steps))
	_shake_tw.tween_property(self, "position", start, dur / float(steps))
