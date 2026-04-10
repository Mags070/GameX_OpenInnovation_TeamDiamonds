extends Area2D

@export var damage: int = 1   # keep small since player has 3 HP

var can_damage = true


func _on_body_entered(body):
	# ❌ Do nothing if cannot damage
	if not can_damage:
		return

	# ❌ Only damage valid targets
	if not body.has_method("take_damage"):
		return

	# ❌ Extra safety: only hit enemies (avoid self-hit bugs)
	if body == get_parent():
		return

	print("Hit:", body.name)

	can_damage = false
	body.take_damage(damage)

	# ⏳ Small cooldown to prevent spam
	await get_tree().create_timer(0.3).timeout
	can_damage = true
