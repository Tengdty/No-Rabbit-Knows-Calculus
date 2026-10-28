extends Label

@export var display_time: float = 2.0  # Time in seconds before text disappears

func _ready() -> void:
	visible = true
	# Create a one-shot timer and wait for it to finish
	await get_tree().create_timer(display_time).timeout
	visible = false
	# Optional: queue_free() if you want to delete the label completely
	# queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
