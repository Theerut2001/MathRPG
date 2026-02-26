# character.gd
extends RefCounted
class_name Character

var name: String
var hp: int
var max_hp: int

func _init(_name: String = "Hero", _max_hp: int = 100) -> void:
	name = _name
	max_hp = max(1, _max_hp)
	hp = max_hp

func clamp_hp() -> void:
	hp = clamp(hp, 0, max_hp)

func is_dead() -> bool:
	return hp <= 0
