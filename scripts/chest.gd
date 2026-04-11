extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var player_nearby: bool = false
var is_opened: bool = false

# Path to your tape scene
const TAPE_SCENE = preload("res://scenes/tape.tscn")
var tape_spawned: bool = false

func _ready() -> void:
	anim.play("idle")

func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("punch"):
		if not is_opened:
			anim.play("open")
			is_opened = true
			print("Chest opened!")
			# Wait for open animation to finish then spawn tape
			anim.animation_finished.connect(_on_open_animation_finished)
		else:
			anim.play("close")
			is_opened = false
			print("Chest closed!")

func _on_open_animation_finished() -> void:
	if is_opened and not tape_spawned:
		tape_spawned = true
		var tape = TAPE_SCENE.instantiate()
		get_parent().add_child(tape)
		tape.global_position = global_position + Vector2(0, -40)
		
		# Play rotate animation on the second AnimatedSprite2D
		tape.get_node("AnimatedSprite2D").play("rotate")
		
		anim.animation_finished.disconnect(_on_open_animation_finished)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "character":
		player_nearby = true
		print("Press punch to open chest")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "character":
		player_nearby = false
