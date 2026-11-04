@tool
extends Node2D

@export_category("Generation Settings")
@export var world_section_scene: PackedScene
@export var tunnel_scene: PackedScene
@export var worlds_path: String = "res://scenes/worlds"
@export var tunnel_spacing: float = 120.0 # Adjust this to space tunnels further apart or closer
@export var world_image_scale: Vector2 = Vector2(0.3, 0.3) # Adjust this to scale the image size

@export_category("Layout & Spacing")
@export var horizontal_spacing: float = 400.0 : set = _set_spacing
@export var center_x_offset: float = 0.0 : set = _set_center_x

func _ready() -> void:
	generate_worlds()
	arrange_worlds()

func _set_spacing(value: float) -> void:
	horizontal_spacing = value
	arrange_worlds()

func _set_center_x(value: float) -> void:
	center_x_offset = value
	arrange_worlds()

func generate_worlds() -> void:
	if not world_section_scene or not tunnel_scene:
		print("WorldManager Error: Please assign WorldSection and Tunnel PackedScenes in the Inspector!")
		return

	# Clear previously generated children safely in the editor
	for child in get_children():
		child.free()

	var dir = DirAccess.open(worlds_path)
	if not dir:
		print("WorldManager Error: Could not open path: ", worlds_path, ". Make sure your 'worlds' folder exists!")
		return

	dir.list_dir_begin()
	var world_folders = []
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			world_folders.append(file_name)
		file_name = dir.get_next()
	
	world_folders.sort()

	var scene_root = get_tree().edited_scene_root if Engine.is_editor_hint() else self

	for world_folder in world_folders:
		var world_path = worlds_path.path_join(world_folder)
		var world_node = world_section_scene.instantiate()
		add_child(world_node)
		
		if Engine.is_editor_hint() and scene_root:
			world_node.owner = scene_root
			set_owner_recursive(world_node, scene_root)

		# Scan the world folder for level files (.tscn) and world image
		var world_dir = DirAccess.open(world_path)
		if world_dir:
			world_dir.list_dir_begin()
			var level_files = []
			var thumbnail_path = ""
			var f_name = world_dir.get_next()
			
			while f_name != "":
				if not world_dir.current_is_dir():
					if f_name.ends_with(".tscn"):
						level_files.append(f_name)
					elif f_name.ends_with(".png"):
						thumbnail_path = world_path.path_join(f_name)
				f_name = world_dir.get_next()
			
			level_files.sort()
			
			# Automatically load and assign the world thumbnail/image if found
			if thumbnail_path != "":
				var tex = load(thumbnail_path) as Texture2D
				if tex:
					# Looks for a node named "WorldImage", or falls back to any Sprite2D inside the world section
					var sprite_node = world_node.get_node_or_null("WorldImage")
					if not sprite_node:
						for child in world_node.find_children("*", "Sprite2D", true, false):
							sprite_node = child
							break
					
					if sprite_node:
						if "texture" in sprite_node:
							sprite_node.texture = tex
						sprite_node.scale = world_image_scale
			
			# Setup tunnels container
			var tunnels_container = world_node.get_node_or_null("Tunnels")
			if not tunnels_container:
				tunnels_container = world_node
			
			# Calculate total width of tunnels to center them neatly under the world image
			var total_tunnel_width = (level_files.size() - 1) * tunnel_spacing
			var current_tunnel_x = - (total_tunnel_width / 2.0)
			
			for level_file in level_files:
				var level_full_path = world_path.path_join(level_file)
				
				var tunnel = tunnel_scene.instantiate()
				tunnel.position.x = current_tunnel_x
				
				if "target_scene" in tunnel:
					tunnel.target_scene = level_full_path
				
				tunnels_container.add_child(tunnel)
				
				if Engine.is_editor_hint() and scene_root:
					tunnel.owner = scene_root
					set_owner_recursive(tunnel, scene_root)
				
				current_tunnel_x += tunnel_spacing

	arrange_worlds()
	print("WorldManager: Successfully generated, textured, and centered worlds and tunnels!")

func set_owner_recursive(node: Node, new_owner: Node) -> void:
	for child in node.get_children():
		child.owner = new_owner
		set_owner_recursive(child, new_owner)

func arrange_worlds() -> void:
	var children = []
	for child in get_children():
		if child is Node2D and not child.is_queued_for_deletion():
			children.append(child)
	
	var count = children.size()
	if count == 0:
		return
		
	var total_width = (count - 1) * horizontal_spacing
	var current_x = center_x_offset - (total_width / 2.0)
	
	for child in children:
		child.position.x = current_x
		child.position.y = 0.0
		current_x += horizontal_spacing
