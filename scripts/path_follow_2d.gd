extends PathFollow2D

@export var speed: float = 100.0  # units per second

func _process(delta: float) -> void:
	progress += speed * delta  # moves along the path
