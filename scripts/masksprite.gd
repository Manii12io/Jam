extends AnimatedSprite2D

func _ready():
	modulate = Color(1, 0, 0, 0.5)  # Make it red and semi-transparent
	play("earth_scater")  # Or any default animation
