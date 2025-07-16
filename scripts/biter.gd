extends CharacterBody2D

@export var speed := 100
@export var player_path := NodePath("../player")
@export var left_limit := -100
@export var right_limit := 100
@export var detection_range := 160.0
@export var attack_range := 30.0
@export var attack_cooldown := 1.0  # Seconds
@export var mask_offset_distance := 30.0  # Distance from enemy toward player

@onready var sprite: AnimatedSprite2D = $normal
@onready var mask: AnimatedSprite2D = $masksprite

var player
var patrol_direction := 1
var start_position := Vector2.ZERO


var is_attacking = false
var attack_timer = 0.0





func _ready():
	player = get_node(player_path)
	start_position = position
	sprite.play("walk")
	sprite.connect("animation_finished", _on_animation_finished)
	mask.visible = false  # Ensure mask is hidden at start


func _physics_process(_delta):
	if not player:
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_player = position.distance_to(player.position)

	if distance_to_player <= detection_range and can_see_player():
		if distance_to_player <= attack_range:
			start_attack()
		else:
			# Chase the player
			var chase_direction = (player.position - position).normalized()
			velocity = chase_direction * speed

			sprite.flip_h = player.position.x < position.x
			sprite.play("walk")
	
		# Patrol mode (same as before)
	elif distance_to_player <= detection_range:
		# Chase the player
		var chase_direction = (player.position - position).normalized()
		velocity = chase_direction * speed

		sprite.flip_h = player.position.x < position.x
		sprite.play("walk")
	else:
		# Patrol mode
		var new_x = position.x + patrol_direction * speed * _delta
		if new_x > start_position.x + right_limit:
			patrol_direction = -1
		elif new_x < start_position.x + left_limit:
			patrol_direction = 1

		velocity.x = patrol_direction * speed
		velocity.y = 0

		sprite.flip_h = patrol_direction < 0
		sprite.play("walk")

	move_and_slide()

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO

	# Calculate direction toward player
	var to_player = (player.position - position).normalized()
	mask.position = to_player * mask_offset_distance

	mask.visible = true
	mask.play("bit_teeth")
	sprite.play("bite")
	



func _on_animation_finished():
	if sprite.animation == "bite":
		is_attacking = false
		mask.visible = false


func can_see_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collide_with_areas = false
	query.collision_mask = 1|2  # <-- Make sure this matches your wall layer

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true
	elif result.collider == player:
		return true
	else:
		return false
