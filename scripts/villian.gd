extends Node2D

const SPEED = 70.0
const ATTACK_RANGE = 60.0
const CHASE_RANGE = 600.0

var direction = 1
var is_active = false
var is_attacking = false
var is_hurt = false
var health = 8
var player = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var punch_zone: Area2D = $punch_zone
@onready var punch_zone2: Area2D = $punch_zone2

func _ready() -> void:
	animated_sprite_2d.visible = true
	set_process(true)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	detection_zone.body_entered.connect(_on_detection_zone_body_entered)
	detection_zone.body_exited.connect(_on_detection_zone_body_exited)
	punch_zone.body_entered.connect(_on_punch_hit)
	punch_zone2.body_entered.connect(_on_punch_hit)
	punch_zone.monitoring = false
	punch_zone.monitorable = false
	punch_zone2.monitoring = false
	punch_zone2.monitorable = false

# ─────────────────────────────────────────────
#  PUNCH ZONE CONTROL
# ─────────────────────────────────────────────
func _set_punch_zones_active(active: bool) -> void:
	if active:
		if direction == 1:
			punch_zone.monitoring = false
			punch_zone.monitorable = false
			punch_zone2.monitoring = true
			punch_zone2.monitorable = true
		else:
			punch_zone.monitoring = true
			punch_zone.monitorable = true
			punch_zone2.monitoring = false
			punch_zone2.monitorable = false
	else:
		punch_zone.monitoring = false
		punch_zone.monitorable = false
		punch_zone2.monitoring = false
		punch_zone2.monitorable = false

# ─────────────────────────────────────────────
#  PUNCH HIT
# ─────────────────────────────────────────────
func _on_punch_hit(body: Node2D) -> void:
	if body.name == "character" and is_attacking:
		if body.has_method("take_damage"):
			body.take_damage(1)

# ─────────────────────────────────────────────
#  DAMAGE / DEATH
# ─────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if is_hurt:
		return
	health -= amount
	print("Villain health: ", health)
	if health <= 0:
		die()
		return
	is_hurt = true
	is_attacking = false
	_set_punch_zones_active(false)
	_flash_hit()

func _flash_hit() -> void:
	for i in range(3):
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
	is_hurt = false

func die() -> void:
	print("Villain died!")
	set_process(false)
	is_hurt = true
	_set_punch_zones_active(false)
	for i in range(5):
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate = Color(1, 1, 1, 0.3)
		await get_tree().create_timer(0.1).timeout
	queue_free()

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
func _on_detection_zone_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.name == "character":
		player = body
		is_active = true
		set_process(true)

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.name == "character":
		player = null
		is_attacking = false
		_set_punch_zones_active(false)
		play_animation("run")

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "punch":
		is_attacking = false
		_set_punch_zones_active(false)

# ─────────────────────────────────────────────
#  MAIN LOOP
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if player == null or is_hurt:
		play_animation("run")
		return

	var distance = global_position.distance_to(player.global_position)

	if player.global_position.x < global_position.x:
		animated_sprite_2d.flip_h = true
		direction = -1
	else:
		animated_sprite_2d.flip_h = false
		direction = 1

	if is_attacking:
		return

	if distance <= ATTACK_RANGE:
		punch()
	elif distance <= CHASE_RANGE:
		chase(delta)
	else:
		patrol(delta)

# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func punch() -> void:
	is_attacking = true
	_set_punch_zones_active(true)
	play_animation("punch")

func chase(delta: float) -> void:
	play_animation("run")
	position.x += direction * SPEED * 1.5 * delta

func patrol(delta: float) -> void:
	if not ray_cast_right.is_colliding() and direction == 1:
		direction = -1
		animated_sprite_2d.flip_h = true
	elif not ray_cast_left.is_colliding() and direction == -1:
		direction = 1
		animated_sprite_2d.flip_h = false
	play_animation("run")
	position.x += direction * SPEED * delta

func play_animation(anim: String) -> void:
	if animated_sprite_2d.animation != anim:
		animated_sprite_2d.play(anim)
