extends VideoStreamPlayer

@export var next_scene: String = "res://scenes/map_2_mirror.tscn"

func _ready():
	print("Playing")
	$VideoStreamPlayer.play()
