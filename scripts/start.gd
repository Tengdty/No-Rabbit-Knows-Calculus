extends Control

func _input(event: InputEvent):
	if event is InputEventKey or event is InputEventMouseButton:
		# Ensure the button was just pressed down, and isn't being held (echo)
		if event.is_pressed() and not event.is_echo():
			# Disable input so it doesn't trigger twice before the scene loads
			set_process_input(false) 
			# Transition to your main game scene
			get_tree().change_scene_to_file("res://scenes/worlds/A- Testing World/testingBegin.tscn")
