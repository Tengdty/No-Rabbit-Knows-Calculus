extends Sprite2D

@export var speed: float = 10.0 # Pixels per second

func _process(delta: float) -> void:
	# Increase X to move right, decrease X to move left
	position.x += speed * delta 
