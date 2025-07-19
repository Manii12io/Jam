extends CharacterBody2D

@export var speed := 100
@export var player_path := NodePath("../../player")
@export var detection_range := 95.0
@export var attack_range := 80.0
@export var attack_cooldown := 2.5  # Seconds
@export var mask_offset_distance := 30.0  # Distance from enemy toward player

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var mask: AnimatedSprite2D = $mask

var player
var is_attacking = false
var attack_timer = 0.0

var health := 60

func take_damage(amount: int):
	health -= amount
	print("Enemy took", amount, "damage. Remaining HP:", health)
	if health <= 0:
		queue_free()
		

func _ready():
	player = get_tree().get_root().get_node("game/player")
	#player = get_node(player_path)
	sprite.play("idle")
	sprite.connect("animation_finished", _on_animation_finished)
	mask.visible = false 

func _physics_process(delta: float) -> void:
	if player==null:
		return
	var _direction = (player.global_position - global_position).normalized()
	var distance_to_player = position.distance_to(player.position)

	# Always reduce attack cooldown timer
	if attack_timer > 0.0:
		attack_timer -= delta

	# Only attack if not currently attacking and cooldown has passed
	if not is_attacking and attack_timer <= 0.0 and distance_to_player <= attack_range:
		is_attacking = true
		attack_timer = attack_cooldown
		velocity = Vector2.ZERO
		sprite.play("teleport")
		mask.visible = false
		mask.speed_scale=0.5
		#mask.global_position = global_position + direction * mask_offset_distance

	move_and_slide()  # Still needed to apply zero movement if body physics are involved

func _on_animation_finished():
	if sprite.animation == "teleport":
		# Direction from player to enemy
		var to_enemy = global_position - player.global_position
		var facing_direction = to_enemy.normalized()

		# Randomly choose either front or back
		var side_multiplier = 1
		if randf() < 0.5:
			side_multiplier = -1

		# Offset enemy position 20–25 pixels in front or behind
		var offset = facing_direction * randf_range(150, 5) * side_multiplier

		global_position = player.global_position + offset

		# Flip enemy sprite if to the left of player
		var should_flip = global_position.x < player.global_position.x
		sprite.flip_h = should_flip
		mask.flip_h = should_flip

# Position the mask relative to the facing direction (left or right)
		if should_flip:
			mask.position.x = abs(mask.position.x)
		else:
			mask.position.x = -abs(mask.position.x)

		
		sprite.play("beam")
	elif sprite.animation == "beam":
		is_attacking = false
		mask.visible = true
		sprite.play("idle")


func can_see_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collide_with_areas = false
	query.collision_mask = 1 | 2  # Update based on your world layers

	var result = space_state.intersect_ray(query)

	return result.is_empty() or result.collider == player
