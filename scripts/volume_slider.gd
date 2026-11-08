extends Control

signal value_changed(value: float)

@export var value: float = 0.5

@onready var bg: Panel = $bg
@onready var fill: Panel = $bg/fill


func _ready() -> void:
	update_slider()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			update_value(event.position.y)

	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_value(event.position.y)


func update_value(mouse_y: float) -> void:
	value = clampf(1.0 - (mouse_y / bg.size.y), 0.0, 1.0)
	update_slider()
	value_changed.emit(value)


func update_slider() -> void:
	var fill_height = bg.size.y * value

	fill.position = Vector2(0, bg.size.y - fill_height)
	fill.size = Vector2(bg.size.x, fill_height)


func _on_volume_slider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		new_value
	)


func _on_button_pressed() -> void:
	pass # Replace with function body.
