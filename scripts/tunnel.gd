extends Area2D

@export_file("*.tscn") var target_scene: String
@onready var prompt_label: Label = $Prompt

var player_in_range: bool = false

func _ready() -> void:
	prompt_label.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	player_in_range = true
	prompt_label.show()

func _on_body_exited(_body: Node2D) -> void:
	player_in_range = false
	prompt_label.hide()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if target_scene:
			get_tree().change_scene_to_file(target_scene)
		else:
			print("Error: Target scene path not set on this tunnel!")
