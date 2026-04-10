extends Node2D

const speed = 60
const ATTACK_RANGE = 80.0
const CHASE_RANGE = 300.0

var direction = 1
var is_active = false
var is_attacking = false
var is_hurt = false
var health = 3
var player = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

func _ready() -> void:
	animated_sprite_2d.visible = false
	set_process(false)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func take_damage(amount: int) -> void:
	if is_hurt:
		return
	health -= amount
	print("Wolf health: ", health)
	if health <= 0:
		die()
		return
	is_hurt = true
	is_attacking = false
	_flash_hit()
	await get_tree().create_timer(0.6).timeout
	is_hurt = false

func _flash_hit() -> void:
	for i in range(3):
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout

func die() -> void:
	print("Wolf died!")
	set_process(false)
	is_hurt = true
	for i in range(4):
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
	queue_free()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.name == "character":
		player = body
		is_active = true
		animated_sprite_2d.visible = true
		set_process(true)

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.name == "character":
		player = null
		is_attacking = false
		play_animation("idle")

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		is_attacking = false

func _process(delta: float) -> void:
	if player == null or is_hurt:
		play_animation("idle")
		return

	var distance = global_position.distance_to(player.global_position)

	# FIXED: flipped the flip_h logic
	if player.global_position.x < global_position.x:
		animated_sprite_2d.flip_h = false
		direction = -1
	else:
		animated_sprite_2d.flip_h = true
		direction = 1

	if is_attacking:
		return

	if distance <= ATTACK_RANGE:
		attack()
	elif distance <= CHASE_RANGE:
		chase(delta)
	else:
		patrol(delta)

func attack() -> void:
	is_attacking = true
	play_animation("attack")

func chase(delta: float) -> void:
	# During chase ignore raycasts — just follow player
	play_animation("walk")
	position.x += direction * speed * 1.5 * delta

func patrol(delta: float) -> void:
	# Use raycasts only during patrol to stay on platform
	if not ray_cast_right.is_colliding() and direction == 1:
		direction = -1
		animated_sprite_2d.flip_h = false
	elif not ray_cast_left.is_colliding() and direction == -1:
		direction = 1
		animated_sprite_2d.flip_h = true
	play_animation("walk")
	position.x += direction * speed * delta

func play_animation(anim: String) -> void:
	if animated_sprite_2d.animation != anim:
		animated_sprite_2d.play(anim)
