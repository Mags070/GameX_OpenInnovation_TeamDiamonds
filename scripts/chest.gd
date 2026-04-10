extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var player_nearby: bool = false
var is_opened: bool = false

func _ready() -> void:
	anim.play("idle")

func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("punch"):
		if not is_opened:
			anim.play("open")
			is_opened = true
			print("Chest opened!")
		else:
			anim.play("close")
			is_opened = false
			print("Chest closed!")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "character":
		player_nearby = true
		print("Press punch to open chest")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "character":
		player_nearby = false
