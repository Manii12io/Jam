extends CharacterBody2D

@export var move_speed: float = 180.0
@export var dodge_speed: float = 350.0
@export var dodge_duration: float = 0.2
@export var dodge_cooldown: float = 0.1

@onready var sprite2d = $AnimatedSprite2D

var is_attacking = false
var is_dodging = false
var dodge_timer = 0.0
var cooldown_timer = 0.0
var dodge_direction = Vector2.ZERO
var last_move_dir = Vector2.DOWN

func _on_animated_sprite_2d_animation_finished():
	if sprite2d.animation.begins_with("attack"):
		is_attacking = false

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	# Save last direction (except during dodge)
	if input_direction != Vector2.ZERO and !is_dodging:
		last_move_dir = input_direction

	# Flip sprite left/right
	var direction_x = Input.get_axis("right", "left")
	if direction_x < 0:
		sprite2d.flip_h = false
	elif direction_x > 0:
		sprite2d.flip_h = true

	# Handle attack (disabled during dodge)
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack") and !is_dodging:
		is_attacking = true
		velocity = Vector2.ZERO
		if abs(last_move_dir.x) > abs(last_move_dir.y):
			sprite2d.play("attack_right")
		elif last_move_dir.y < 0:
			sprite2d.play("attack_up")
		else:
			sprite2d.play("attack_down")
		move_and_slide()
		return

	# Handle dodge movement
	if is_dodging:
		velocity = dodge_direction * dodge_speed
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
			cooldown_timer = dodge_cooldown
		move_and_slide()
		return
	elif cooldown_timer > 0:
		cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0:
		is_dodging = true
		dodge_timer = dodge_duration
		dodge_direction = input_direction if input_direction != Vector2.ZERO else last_move_dir
		# Optional: sprite2d.play("roll") for roll animation
		move_and_slide()
		return

	# Movement animation
	if input_direction == Vector2.ZERO:
		sprite2d.play("idle")
	elif input_direction.y < 0:
		sprite2d.play("upside")
	elif input_direction.y > 0:
		sprite2d.play("downside")
	else:
		sprite2d.play("walk")

	# Normal movement
	velocity = input_direction * move_speed
	move_and_slide()
