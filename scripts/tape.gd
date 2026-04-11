extends StaticBody2D

@export var tape_name: String = "tape_1"
@export var tape_sound: AudioStream

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_playing: bool = false

func _ready() -> void:
	anim.play("rotate")

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "character" and not is_playing:
		is_playing = true
		Inventory.add_item(
			tape_name,
			"A mysterious old tape",   # description
			"res://icons/tape.png"     # icon path
		)
		print(tape_name + " equipped!")
		
		if tape_sound:
			audio.stream = tape_sound
			audio.play()
			await audio.finished
		
		queue_free()
