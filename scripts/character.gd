extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_punching = false
var health = 5
var can_take_damage = true
var damage_cooldown = 1.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var punch_zone: Area2D = $punch_zone
@onready var punch_zone_2: Area2D = $punch_zone2

func _ready() -> void:
	punch_zone.monitoring = false
	punch_zone_2.monitoring = false
	punch_zone.area_entered.connect(_on_punch_zone_area_entered)
	punch_zone_2.area_entered.connect(_on_punch_zone_area_entered)
	if Inventory.has_item("tape"):
		print("Player has tape!")

func take_damage(amount: int) -> void:
	if not can_take_damage:
		return
	health -= amount
	print("Player health: ", health)
	can_take_damage = false
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.3).timeout
	animated_sprite.modulate = Color.WHITE
	await get_tree().create_timer(damage_cooldown).timeout
	can_take_damage = true
	if health <= 0:
		die()

func die() -> void:
	print("Player died!")
	get_tree().reload_current_scene()

func _on_punch_zone_area_entered(area: Area2D) -> void:
	if area.name == "HitBox":
		var wolf = area.get_parent()
		if wolf.has_method("take_damage"):
			print("Wolf hit!")
			wolf.take_damage(1)

func _on_punch_zone_body_entered(body: Node2D) -> void:
	pass

func _on_punch_zone_body_exited(body: Node2D) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump cancels punch
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_stop_punch()

	# Punch HELD — keep punching while button is held
	if Input.is_action_pressed("punch") and is_on_floor() and not is_punching:
		_start_punch()

	# Punch released — cancel immediately
	if Input.is_action_just_released("punch"):
		_stop_punch()

	# Auto stop when animation ends
	if is_punching and not animated_sprite.is_playing():
		if Input.is_action_pressed("punch") and is_on_floor():
			animated_sprite.play("punch")
		else:
			_stop_punch()

	var direction := Input.get_axis("move_left", "move_right")

	if is_punching:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		animated_sprite.flip_h = false
		punch_zone.position.x = abs(punch_zone.position.x)
		punch_zone_2.position.x = abs(punch_zone_2.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		punch_zone.position.x = -abs(punch_zone.position.x)
		punch_zone_2.position.x = -abs(punch_zone_2.position.x)

	if not is_punching:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("running")
			else:
				animated_sprite.play("running")
		else:
			animated_sprite.play("jump")

	move_and_slide()

func _start_punch() -> void:
	is_punching = true
	punch_zone.monitoring = true
	punch_zone_2.monitoring = true
	animated_sprite.play("punch")

func _stop_punch() -> void:
	is_punching = false
	punch_zone.monitoring = false
	punch_zone_2.monitoring = false
	animated_sprite.stop()
