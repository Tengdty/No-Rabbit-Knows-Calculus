extends Node

const WORLDS_DIR := "res://scenes/worlds"

func advance_level() -> void:
	var current_path := get_tree().current_scene.scene_file_path
	var current_world_dir := current_path.get_base_dir()
	var current_world_name := current_world_dir.get_file()

	var worlds := DirAccess.open(WORLDS_DIR)
	if worlds == null:
		push_error("Can't open worlds directory: " + WORLDS_DIR)
		return

	var world_names := worlds.get_directories()
	world_names.sort()

	var world_index := world_names.find(current_world_name)
	if world_index == -1:
		push_error("Current world folder isn't under " + WORLDS_DIR)
		return

	var level_files := _scene_files(current_world_dir)
	var level_index := level_files.find(current_path.get_file())

	# Advance to the next scene in this world.
	if level_index >= 0 and level_index + 1 < level_files.size():
		_load_scene(current_world_dir.path_join(level_files[level_index + 1]))
		return

	# This world is finished; find the first scene in a later non-empty world.
	for i in range(world_index + 1, world_names.size()):
		var next_world_dir := WORLDS_DIR.path_join(world_names[i])
		var next_world_levels := _scene_files(next_world_dir)

		if not next_world_levels.is_empty():
			_load_scene(next_world_dir.path_join(next_world_levels[0]))
			return

	push_warning("No later levels found.")

func _scene_files(folder: String) -> PackedStringArray:
	var dir := DirAccess.open(folder)
	var scenes := PackedStringArray()

	if dir == null:
		return scenes

	for file in dir.get_files():
		if file.ends_with(".tscn"):
			scenes.append(file)

	scenes.sort()
	return scenes

func _load_scene(path: String) -> void:
	get_tree().call_deferred("change_scene_to_file", path)
