class_name HitBox
extends Area2D

@export var dmg:=10

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
	
func _on_HitBox_body_entered(body):
	if body.is_in_group("enemies"):  # Ensure enemy is in this group
		if body.has_method("apply_damage"):
			body.apply_damage(dmg)
