extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer2/Button.process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer2/Button.text = "Restart"
	$CenterContainer/VBoxContainer2/Button.pressed.connect(_on_restart_pressed)
	visible = false

func show_death_screen():
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	var current_scene = get_tree().current_scene
	get_tree().change_scene_to_file(current_scene.scene_file_path)
