# File: HurtBox.gd
class_name HurtBox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2  # Detect hitboxes

func _ready() -> void:
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area == null:
		return

	var hitbox := area as HitBox
	if hitbox and owner and owner.has_method("take_damage"):
		owner.call("take_damage", hitbox.dmg)  # Changed from hitbox.damage
