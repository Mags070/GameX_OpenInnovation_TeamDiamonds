extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "wolf":
		body.take_damage(1)
	if body.name=="villian":
		body.take_damage(1)
