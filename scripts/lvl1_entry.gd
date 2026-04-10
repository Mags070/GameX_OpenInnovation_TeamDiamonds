extends Area2D

var player_inside: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "character":
		player_inside = true
		print("Press Enter to go to next area")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "character":
		player_inside = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/map_1.tscn")
