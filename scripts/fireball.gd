extends Area2D

@onready var timer: Timer = $Timer

var move_speed: float = 2.0
var move_distance: float = 50.0
var start_position: Vector2
var direction: float = 1.0

func _ready() -> void:
	start_position = global_position

func _process(delta: float) -> void:
	global_position.y += move_speed * direction * delta * 60
	
	if global_position.y > start_position.y + move_distance:
		direction = -1.0
	elif global_position.y < start_position.y - move_distance:
		direction = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "character":
		print("U died")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").set_deferred("disabled", true)
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
