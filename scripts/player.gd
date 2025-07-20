extends CharacterBody2D

@export var move_speed: float = 100.0
@export var dodge_speed: float = 350.0
@export var dodge_duration: float = 0.25
@export var dodge_cooldown: float = 0.01

@onready var animate = $AnimationPlayer
@onready var hitbox = $HitBox
@onready var sprite = $Sprite2D  # For flip_h if still needed
@onready var hurtbox = $Sprite2D/HurtBox
@onready var death_screen=get_node("../ui/death")

var is_attacking = false
var is_dodging = false
var is_dead=false
var dodge_timer = 0.0
var cooldown_timer = 0.0
var dodge_direction = Vector2.ZERO
var last_move_dir = Vector2.DOWN


var health := 10

func show_death_screen():
	death_screen.show_death_screen()



func take_damage(amount: int):
	if is_dead:
		return
	health -= amount
	print("Enemy took", amount, "damage. Remaining HP:", health)
	if health <= 0:
		is_dead = true
		animate.play("Death")
		show_death_screen()
		

func _ready():
	animate.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"))
	hitbox.set_deferred("monitoring", false)
	hitbox.monitoring=false
	$HitBox/Attack_Up.disabled = true
	$HitBox/Attack_RL.disabled = true
	$HitBox/Attack_Down.disabled = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name.begins_with("Death"):
		queue_free() 
		return
	
	if anim_name.begins_with("Attack"):
		print("Attack animation finished. Disabling hitbox.")
		is_attacking = false
		hitbox.monitoring = false
		hurtbox.monitoring=true

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	
	if input_direction != Vector2.ZERO and !is_dodging:
		last_move_dir = input_direction

	# Flip sprite if needed
	var direction_x = Input.get_axis("right", "left")
	if direction_x < 0:
		sprite.flip_h = false
	elif direction_x > 0:
		sprite.flip_h = true
		
	


	# Handle attack
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack") and !is_dodging:
		is_attacking = true
		hitbox.monitoring = true
		hurtbox.monitoring = false
		velocity = Vector2.ZERO

		# Play appropriate attack animation
		if abs(last_move_dir.x) > abs(last_move_dir.y):
			animate.play("Attack_RL")
			hitbox.position = Vector2(20 * sign(last_move_dir.x), 0)
		elif last_move_dir.y < 0:
			animate.play("Attack_Up")
			hitbox.position = Vector2(0, -20)
		else:
			animate.play("Attack_Down")
			hitbox.position = Vector2(0, 20)

		move_and_slide()
		return

	# Handle dodge
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
		#animate.play("roll")  # Optional: use if you have a roll animation
		move_and_slide()
		return

	# Movement animation
	if input_direction == Vector2.ZERO:
		animate.play("Idle_RL")
	elif input_direction.y < 0:
		animate.play("Walk_Up")
	elif input_direction.y > 0:
		animate.play("Walk_Down")
	else:
		animate.play("Walk_RL")

	# Apply velocity
	velocity = input_direction * move_speed
	move_and_slide()

	# Disable hitbox after attack end
