extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	if music:
		music.stream.loop = true
		music.play()
	else:
		print("AudioStreamPlayer not found!")
