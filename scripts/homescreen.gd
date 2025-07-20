extends CanvasLayer


func _ready():
	$"VBoxContainer/start game".text = "Start Game"
	#$VBoxContainer/optidon.text = "Settings"
	$VBoxContainer/quit.text = "Quit"

	$"VBoxContainer/start game".pressed.connect(_on_start_pressed)
	#$VBoxContainer/option.pressed.connect(_on_settings_pressed)
	$VBoxContainer/quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scene/game.tscn")  # Change to your main game scene

#func _on_settings_pressed():
	#print("Settings button clicked")  # Or open a settings scene/popup

func _on_quit_pressed():
	get_tree().quit()
