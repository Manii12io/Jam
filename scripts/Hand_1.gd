extends CharacterBody2D

var x_move = randf_range(-100,100)
var y_move = randf_range(-100,100)
var timer_active = false
var attcking = false
var attack = 0

func _ready() -> void:
	$AnimationPlayer_Hand.play("Idle_hand")

func _physics_process(_delta: float) -> void:
	velocity = Vector2(x_move,y_move)
	if timer_active == false:
		timer()
	if timer_active == true:
		timer_reset()
	
	attack_now()
	
	
	move_and_slide()

func timer():
	await get_tree().create_timer(2).timeout
	x_move = randf_range(-100,100)
	y_move = randf_range(-100,100)
	timer_active = true
	attcking = true
	attack = randi_range(1,2)
	

func timer_reset():
	timer_active = false
	

func attack_now():
	if attack == 1:
		$AnimationPlayer_Hand.play("Explode")
	if attack == 2:
		$AnimationPlayer_Hand.play("Drag")
