extends Node

const SETTINGS_SCENE: PackedScene = preload("res://assets/ui-elements/settings.tscn")

var settings_open: bool = false
var settings_instance: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_settings") and not event.is_echo():
		if settings_open:
			close_settings()
		else:
			open_settings()


func open_settings() -> void:
	if settings_open:
		return

	settings_open = true

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)

	settings_instance = SETTINGS_SCENE.instantiate()
	settings_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_instance.set_meta("settings_manager", self)

	canvas_layer.add_child(settings_instance)

	get_tree().paused = true


func close_settings() -> void:
	if not settings_open:
		return

	settings_open = false
	get_tree().paused = false

	if is_instance_valid(settings_instance):
		settings_instance.get_parent().queue_free()

	settings_instance = null
