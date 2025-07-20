extends CharacterBody2D
var x_move = randf_range(-100,100)
var y_move = randf_range(-100,100)
var timer_active = false


var health := 60

func take_damage(amount: int):
	health -= amount
	print("Enemy took", amount, "damage. Remaining HP:", health)
	if health <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	velocity = Vector2(x_move,y_move)
	if timer_active == false:
		timer()
	if timer_active == true:
		timer_reset()
	
	$AnimationPlayer.play("Idle")
	move_and_slide()

func timer():
	await get_tree().create_timer(2).timeout
	x_move = randf_range(-100,100)
	y_move = randf_range(-100,100)
	timer_active = true
	

func timer_reset():
	timer_active = false
	
