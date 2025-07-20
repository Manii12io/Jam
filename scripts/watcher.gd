extends CharacterBody2D

@export var speed := 100
@export var player_path := NodePath("../../player")
@export var detection_range := 95.0
@export var attack_range := 80.0
@export var attack_cooldown := 2.5  # Seconds
@export var mask_offset_distance := 30.0  # Distance from enemy toward player
 # or whatever your visual mask node is


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var mask_sprite: Sprite2D = $mask
@onready var mask_anim: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $AnimatedSprite2D/HurtBox
@onready var hitbox: Area2D = $HitBox
@onready var shape_mask: CollisionShape2D = $HitBox/CollisionShape2D

var player
var is_attacking = false
var attack_timer = 0.0
var health := 60
var is_dead = false

func _ready():
	player = get_tree().get_root().get_node("game/player")
	sprite.play("idle")
	sprite.connect("animation_finished", _on_animation_finished)
	mask_sprite.visible = false
	hitbox.monitoring = false
	shape_mask.disabled = true

func take_damage(amount: int):
	if is_dead or not hurtbox.monitoring:
		return
	health -= amount
	print("Enemy took", amount, "damage. Remaining HP:", health)
	if health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		sprite.play("death")

func _physics_process(delta: float) -> void:
	if not player:
		return

	var distance_to_player = position.distance_to(player.position)

	# Attack cooldown
	if attack_timer > 0.0:
		attack_timer -= delta

	if not is_attacking and attack_timer <= 0.0 and distance_to_player <= attack_range:
		is_attacking = true
		attack_timer = attack_cooldown
		velocity = Vector2.ZERO
		sprite.play("teleport")
		mask_sprite.visible = false
		mask_anim.stop()
		hurtbox.monitoring = false
		hitbox.monitoring = false
		shape_mask.disabled = true

	move_and_slide()

func _on_animation_finished():
	if sprite.animation == "death":
		queue_free()

	elif sprite.animation == "teleport":
		# Teleport logic
		var to_enemy = global_position - player.global_position
		var facing_direction = to_enemy.normalized()
		var side_multiplier = -1 if randf() < 0.5 else 1
		var offset = facing_direction * randf_range(150, 5) * side_multiplier

		global_position = player.global_position + offset

				# Flip direction
		var should_flip = global_position.x < player.global_position.x
		sprite.flip_h = should_flip
		mask_sprite.flip_h = should_flip

		# Flip hurtbox and mask visual positions
		hurtbox.position.x = abs(hurtbox.position.x) if should_flip else -abs(hurtbox.position.x)
		mask_sprite.position.x = abs(mask_sprite.position.x) if should_flip else -abs(mask_sprite.position.x)

		# www Flip the HitBox along with the mask
		hitbox.position.x = abs(hitbox.position.x) if should_flip else -abs(hitbox.position.x)



		# Begin attack phase
		sprite.play("beam")
		mask_sprite.visible = true
		mask_anim.play("beam")  # <- adjust if needed
		hitbox.monitoring = true
		shape_mask.disabled = false

	elif sprite.animation == "beam":
		is_attacking = false
		hurtbox.monitoring = true
		hitbox.monitoring = false
		shape_mask.disabled = true
		mask_sprite.visible = false
		sprite.play("idle")

func can_see_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collide_with_areas = false
	query.collision_mask = 1 | 2
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.collider == player
