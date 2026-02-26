# math_gen.gd
extends RefCounted
class_name MathGen

enum Difficulty { EASY, NORMAL, HARD, VERY_HARD }

var _rng := RandomNumberGenerator.new()

func _init() -> void:
	_rng.randomize()

func make_problem(diff: Difficulty) -> Dictionary:
	var pick := _rng.randi_range(1, 100)
	match diff:
		Difficulty.EASY:
			return _easy(pick)
		Difficulty.NORMAL:
			return _normal(pick)
		Difficulty.HARD:
			return _hard(pick)
		Difficulty.VERY_HARD:
			return _very_hard(pick)
		_:
			return _normal(pick)

func check_answer(user_text: String, problem: Dictionary) -> bool:
	var expected: Variant = problem.get("ans", null)
	var tol: float = float(problem.get("tolerance", 0.0))

	var t := user_text.strip_edges()
	if t.is_empty():
		return false

	if t.contains("/"):
		var parts := t.split("/", false)
		if parts.size() != 2:
			return false
		var a_txt := parts[0].strip_edges()
		var b_txt := parts[1].strip_edges()
		if not _is_number(a_txt) or not _is_number(b_txt):
			return false
		var a := a_txt.to_float()
		var b := b_txt.to_float()
		if is_zero_approx(b):
			return false
		return _compare_numeric(expected, a / b, tol)

	if not _is_number(t):
		return false

	return _compare_numeric(expected, t.to_float(), tol)

func _compare_numeric(expected: Variant, got: float, tol: float) -> bool:
	if expected == null:
		return false
	if typeof(expected) == TYPE_INT:
		return int(round(got)) == int(expected)
	return abs(got - float(expected)) <= tol

# ------------------------------
# EASY (Defend): + - × ÷ (เลขเล็ก)
# ------------------------------
func _easy(pick: int) -> Dictionary:
	var a: int = _rng.randi_range(1, 15)
	var b: int = _rng.randi_range(1, 15)

	if pick <= 30:
		return _pack("%d + %d = ?" % [a, b], a + b, 0.0, "Arithmetic", "Easy")
	elif pick <= 60:
		return _pack("%d - %d = ?" % [a, b], a - b, 0.0, "Arithmetic", "Easy")
	elif pick <= 85:
		var m1: int = _rng.randi_range(2, 9)
		var m2: int = _rng.randi_range(2, 9)
		return _pack("%d × %d = ?" % [m1, m2], m1 * m2, 0.0, "Arithmetic", "Easy")
	else:
		var d: int = _rng.randi_range(2, 9)
		var ans: int = _rng.randi_range(2, 12)
		var n: int = d * ans
		return _pack("%d ÷ %d = ?" % [n, d], ans, 0.0, "Arithmetic", "Easy")

# ------------------------------
# NORMAL (Attack): + - × ÷ (เลขกลาง)
# ------------------------------
func _normal(pick: int) -> Dictionary:
	if pick <= 30:
		var a: int = _rng.randi_range(10, 60)
		var b: int = _rng.randi_range(10, 60)
		return _pack("%d + %d = ?" % [a, b], a + b, 0.0, "Arithmetic", "Normal")
	elif pick <= 60:
		var a2: int = _rng.randi_range(20, 80)
		var b2: int = _rng.randi_range(5, 40)
		return _pack("%d - %d = ?" % [a2, b2], a2 - b2, 0.0, "Arithmetic", "Normal")
	elif pick <= 85:
		var m1: int = _rng.randi_range(5, 15)
		var m2: int = _rng.randi_range(5, 15)
		return _pack("%d × %d = ?" % [m1, m2], m1 * m2, 0.0, "Arithmetic", "Normal")
	else:
		var d: int = _rng.randi_range(3, 12)
		var ans: int = _rng.randi_range(5, 20)
		var n: int = d * ans
		return _pack("%d ÷ %d = ?" % [n, d], ans, 0.0, "Arithmetic", "Normal")

# HARD/VERY_HARD เก็บไว้ให้ Heal/Special (จะเป็น Algebra/Quadratic ได้)
func _hard(pick: int) -> Dictionary:
	if pick <= 55:
		var x: int = _rng.randi_range(-10, 10)
		var a: int = _rng.randi_range(2, 8)
		var b: int = _rng.randi_range(-12, 12)
		var c: int = a * (x + b)
		var eq: String = "%d%s = %d" % [a, _fmt_paren_linear("x", b), c]
		return _pack("Solve: %s.  x = ?" % eq, x, 0.0, "Algebra", "Hard")

	var roots: PackedInt32Array = _pick_distinct_int_roots(-9, 9)
	var r: int = roots[0]
	var s: int = roots[1]
	var B: int = -(r + s)
	var C: int = r * s
	var ans_small: int = min(r, s)
	var eq2: String = _fmt_quadratic(1, B, C)
	return _pack("Quadratic: %s  Give the smaller root." % eq2, ans_small, 0.0, "Quadratic", "Hard")

func _very_hard(pick: int) -> Dictionary:
	if pick <= 60:
		var x: int = _rng.randi_range(-15, 15)
		var a: int = _rng.randi_range(2, 10)
		var b: int = _rng.randi_range(-15, 15)
		var c: int = _rng.randi_range(-25, 25)
		var k: int = a * (x + b) + c
		var left: String = "%d%s%s" % [a, _fmt_paren_linear("x", b), _fmt_const(c)]
		var eq: String = "%s = %d" % [left.strip_edges(), k]
		return _pack("Solve: %s.  x = ?" % eq, x, 0.0, "Algebra", "VeryHard")

	var roots: PackedInt32Array = _pick_distinct_int_roots(-12, 12)
	var r: int = roots[0]
	var s: int = roots[1]
	var B: int = -(r + s)
	var C: int = r * s
	var ans_big: int = max(r, s)
	var eq2: String = _fmt_quadratic(1, B, C)
	return _pack("Quadratic: %s  Give the larger root." % eq2, ans_big, 0.0, "Quadratic", "VeryHard")

# -------- helpers --------

func _is_number(s: String) -> bool:
	var t := s.strip_edges()
	if t.is_empty():
		return false
	var v := t.to_float()
	if is_zero_approx(v):
		return t == "0" or t == "0.0" or t == "-0" or t == "-0.0"
	return true

func _sign(n: int) -> String:
	return "+" if n >= 0 else "-"

func _abs_i(n: int) -> int:
	return n if n >= 0 else -n

func _fmt_const(b: int) -> String:
	return " %s %d" % [_sign(b), _abs_i(b)]

func _fmt_paren_linear(xname: String, b: int) -> String:
	if b == 0:
		return "(%s)" % xname
	return "(%s %s %d)" % [xname, _sign(b), _abs_i(b)]

func _fmt_x(a: int) -> String:
	if a == 0:
		return ""
	var s := _sign(a)
	var aa := _abs_i(a)
	if aa == 1:
		return " %s x" % s
	return " %s %dx" % [s, aa]

func _fmt_x2(a: int) -> String:
	if a == 1:
		return "x²"
	if a == -1:
		return "-x²"
	return "%dx²" % a

func _fmt_quadratic(a: int, b: int, c: int) -> String:
	var s := _fmt_x2(a)
	s += _fmt_x(b)
	s += _fmt_const(c)
	return "%s = 0" % s.strip_edges()

func _pick_distinct_int_roots(lo: int, hi: int) -> PackedInt32Array:
	var r: int = _rng.randi_range(lo, hi)
	var s: int = _rng.randi_range(lo, hi)
	while s == r:
		s = _rng.randi_range(lo, hi)
	return PackedInt32Array([r, s])

func _pack(q: String, ans: Variant, tol: float, topic: String, diff: String) -> Dictionary:
	return {"q": q, "ans": ans, "tolerance": tol, "topic": topic, "diff": diff}
