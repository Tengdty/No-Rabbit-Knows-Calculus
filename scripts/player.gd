extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# jump arrow variables
@onready var arrowRoot: Node2D = $jumparrowroot
@onready var arrowSprite: Sprite2D = $jumparrowroot/arrow

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SETTINGS_SCENE = preload("res://assets/ui-elements/settings.tscn")

# the rotation amount the arrow change
var arrowSpeed: float = -75
var jumpPower: float = 700.0

# NOTE this script is a **template** by godot

func _physics_process(delta: float) -> void:
	
	# TODO change animation to walking when velocity > 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/100)

	move_and_slide()
	
	# change direction the sprite is facing
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true

# processed every frame or smth
func _process(delta: float) -> void:
	arrowRoot.global_rotation_degrees += arrowSpeed * delta
	
	# reverse the direction of rotation.
	if arrowRoot.global_rotation_degrees <= -170 or arrowRoot.global_rotation_degrees >= -10:
		arrowSpeed *= -1

# jump in the direction of the arrow
func jump():
	var jumpDir: Vector2 = (arrowSprite.global_position - global_position).normalized()
	velocity.y = jumpDir.y * jumpPower
	velocity.x = jumpDir.x * jumpPower


func _on_button_pressed() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	var settings = SETTINGS_SCENE.instantiate()
	canvas_layer.add_child(settings)
	get_tree().paused = true
	
	print("SUCCESSFUL PRESS")
