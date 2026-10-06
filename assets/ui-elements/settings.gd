extends Control

@onready var music_slider = $MarginContainer/VBoxContainer/Music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var db = AudioServer.get_bus_volume_db(music_bus)

	music_slider.value = db_to_linear(db)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_parent().queue_free()
