extends CanvasLayer

@onready var restart_button: Button = $CenterContainer/VBoxContainer/Button # <-- match your real path

func _ready():
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.text = "Restart"
	restart_button.pressed.connect(_on_restart_pressed)
	visible = false

func show_death_screen():
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	var current_scene = get_tree().current_scene
	get_tree().change_scene_to_file(current_scene.scene_file_path)
