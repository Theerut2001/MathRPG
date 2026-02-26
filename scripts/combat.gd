# combat.gd
extends RefCounted
class_name Combat

enum ActionType { ATTACK, DEFEND, HEAL, SPECIAL }

class CombatCharacter:
	var name: String
	var hp: int
	var max_hp: int
	var atk: int
	var defense: int
	var heal_power: int
	var defending: bool = false

	func _init(n: String, mhp: int, _atk: int = 0, _def: int = 0, _heal: int = 0) -> void:
		name = n
		max_hp = max(1, mhp)
		hp = max_hp
		atk = _atk
		defense = _def
		heal_power = _heal

	func clamp_hp() -> void:
		hp = clamp(hp, 0, max_hp)

	func is_dead() -> bool:
		return hp <= 0

func _base_value(diff: String) -> int:
	match diff:
		"Easy": return 10
		"Normal": return 14
		"Hard": return 18
		"VeryHard": return 22
	return 12

func _apply_defense(dmg: int, target: CombatCharacter) -> int:
	var out: int = dmg - target.defense
	return max(1, out)

# Returns Dictionary:
# { "log": String, "dmg": int, "heal": int, "success": bool }
func apply_player_action(
	player: CombatCharacter,
	enemy: CombatCharacter,
	action: ActionType,
	correct: bool,
	diff_label: String
) -> Dictionary:
	player.defending = false

	if not correct:
		return {"log":"Wrong answer! Action failed.", "dmg":0, "heal":0, "success":false}

	var base: int = _base_value(diff_label)

	match action:
		ActionType.ATTACK:
			var raw: int = base + player.atk
			var dmg: int = _apply_defense(raw, enemy)
			enemy.hp -= dmg
			enemy.clamp_hp()
			return {"log":"Attack hits for %d damage!" % dmg, "dmg":dmg, "heal":0, "success":true}

		ActionType.DEFEND:
			player.defending = true
			return {"log":"You brace for impact (Defend).", "dmg":0, "heal":0, "success":true}

		ActionType.HEAL:
			var scaled_f: float = float(base) * 0.8
			var h: int = int(round(scaled_f)) + player.heal_power
			h = max(1, h)
			player.hp += h
			player.clamp_hp()
			return {"log":"You heal for %d HP!" % h, "dmg":0, "heal":h, "success":true}

		ActionType.SPECIAL:
			var scaled2_f: float = float(base) * 1.4
			var raw2: int = int(round(scaled2_f)) + int(round(float(player.atk) * 1.2))
			var dmg2: int = _apply_defense(raw2, enemy)
			enemy.hp -= dmg2
			enemy.clamp_hp()
			return {"log":"Special strike deals %d damage!" % dmg2, "dmg":dmg2, "heal":0, "success":true}

	return {"log":"Action done.", "dmg":0, "heal":0, "success":true}

# Returns Dictionary:
# { "log": String, "dmg": int, "heal": int }
func enemy_turn(player: CombatCharacter, enemy: CombatCharacter, rng: RandomNumberGenerator) -> Dictionary:
	enemy.defending = false

	var will_heal: bool = false
	if enemy.hp <= int(float(enemy.max_hp) * 0.35) and rng.randf() < 0.40:
		will_heal = true

	if will_heal:
		var h: int = rng.randi_range(6, 12) + enemy.heal_power
		enemy.hp += h
		enemy.clamp_hp()
		return {"log":"Enemy uses Heal (+%d)!" % h, "dmg":0, "heal":h}

	var raw: int = rng.randi_range(10, 16) + enemy.atk
	var dmg: int = raw - player.defense
	dmg = max(1, dmg)

	if player.defending:
		dmg = int(round(float(dmg) * 0.5))

	player.hp -= dmg
	player.clamp_hp()
	return {"log":"Enemy attacks for %d damage!" % dmg, "dmg":dmg, "heal":0}
