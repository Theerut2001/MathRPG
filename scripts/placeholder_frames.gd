extends Node2D
class_name PlaceholderBattler

@export var base_color: Color = Color(0.3, 0.9, 0.6) # player green
@export var size: Vector2i = Vector2i(96, 96)

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spr.sprite_frames = SpriteFrames.new()

	_add_anim("idle", 8, 8.0, true, base_color)
	_add_anim("attack", 6, 10.0, false, base_color.lightened(0.15))
	_add_anim("hurt", 4, 12.0, false, Color(1, 0.4, 0.4))
	_add_anim("heal", 4, 12.0, false, Color(0.4, 1, 0.6))

	spr.play("idle")

func _add_anim(name: String, frame_count: int, fps: float, loop: bool, c: Color) -> void:
	spr.sprite_frames.add_animation(name)
	spr.sprite_frames.set_animation_speed(name, fps)
	spr.sprite_frames.set_animation_loop(name, loop)

	for i in range(frame_count):
		# เปลี่ยนสี/ความสว่างเล็กน้อยให้ดูเหมือนมีการเคลื่อนไหว
		var denom: float = float(frame_count - 1)
		if denom < 1.0:
			denom = 1.0
		var t: float = float(i) / denom
		var col := c.lerp(c.darkened(0.25), abs(sin(t * PI)))

		# ทำ texture เป็นรูปสี่เหลี่ยม
		var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))

		# วาดสี่เหลี่ยมมีขอบ + highlight
		var border := 6
		_fill_rect(img, Rect2i(0, 0, size.x, size.y), col.darkened(0.35))
		_fill_rect(img, Rect2i(border, border, size.x - border * 2, size.y - border * 2), col)
		_fill_rect(img, Rect2i(border + 10, border + 10, 22, 22), col.lightened(0.35)) # highlight corner

		# ทำเฟรม attack ให้ “ยื่น” ออกนิดหน่อย
		if name == "attack":
			var poke := int(round(10 * sin(t * PI)))
			# แค่ shift offset ด้วยการวาดซ้ำอีกชั้น
			_fill_rect(img, Rect2i(border + poke, border + 30, 26, 18), col.lightened(0.2))

		var tex := ImageTexture.create_from_image(img)
		spr.sprite_frames.add_frame(name, tex)

func _fill_rect(img: Image, r: Rect2i, col: Color) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, col)
