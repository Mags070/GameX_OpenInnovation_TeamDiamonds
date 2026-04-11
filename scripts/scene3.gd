extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video_stream_player.play()
	print(video_stream_player.stream)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	get_tree().change_scene_to_file("res://scenes/map_1.tscn")
	
