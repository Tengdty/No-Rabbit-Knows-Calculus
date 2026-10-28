extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrowRoot: Node2D = $jumparrowroot
@onready var arrowSprite: Sprite2D = $jumparrowroot/arrow

var charge_time: float = 0.0
var isJumping: bool = false
const SPEED_PEN: float = 0.05
const MIN_JUMP_POWER: float = 400.0
const MAX_JUMP_POWER: float = 600.0
const MAX_CHARGE_TIME: float = 2.0
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const SETTINGS_SCENE: Resource = preload("res://assets/ui-elements/settings.tscn")

# the rotation amount the arrow change
var arrowSpeed: float = -150
var jumpPower: float = 700.0

func _physics_process(delta: float) -> void:
	# saving this variable since its reused
	var onFloor: bool = is_on_floor()
	var direction: float = 0.0
	
	# Add the gravity.
	if not onFloor:
		velocity += get_gravity() * delta
	else:
		# Only check for left/right input if we are on the ground
		direction = Input.get_axis("move_left", "move_right")
		
		if direction and not isJumping:
			velocity.x = direction * SPEED
		elif direction and isJumping:
			velocity.x = direction * SPEED * SPEED_PEN
		else:
			# this is essentially friction to your horizontal speed.
			velocity.x = move_toward(velocity.x, 0, SPEED/3)

		# Change direction the sprite is facing (Only update while walking)
		if not isJumping:
			if direction > 0.0:
				animated_sprite_2d.flip_h = false
			elif direction < 0.0:
				animated_sprite_2d.flip_h = true

	move_and_slide()

# processed every frame or smth
func _process(delta: float) -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		charge_time += delta
		isJumping = true
		# Update animation based on how long the button is held
		if charge_time > 2.0:
			animated_sprite_2d.play("charge_3")
		elif charge_time > 1.0:
			animated_sprite_2d.play("charge_2")
		else:
			animated_sprite_2d.play("charge_1")
	elif Input.is_action_just_released("jump") and is_on_floor():
		# Trigger the actual jump
		animated_sprite_2d.play("jump")
		jump()
		isJumping = false
		arrowRoot.visible = false
		charge_time = 0.0 # Reset for the next jump
	else:
		# Handle standard grounded animations when not charging/jumping
		if is_on_floor():
			if velocity.x == 0:
				animated_sprite_2d.play("idle")
			else:
				pass #animated_sprite_2d.play("walk")
	
	if isJumping:
		arrowRoot.visible = true
		var val = arrowSpeed * delta
		if Input.is_action_pressed("turn_left") and not arrowRoot.global_rotation_degrees - val <= -170 :
			arrowRoot.global_rotation_degrees += val
		elif Input.is_action_pressed("turn_right") and not arrowRoot.global_rotation_degrees + val >= -10:
			arrowRoot.global_rotation_degrees -= val

# jump in the direction of the arrow
func jump() -> void:
	# Calculate the power based on charge time
	var charge_percent = clamp(charge_time / MAX_CHARGE_TIME, 0.0, 1.0)
	
	var power = abs(lerp(MIN_JUMP_POWER, MAX_JUMP_POWER, charge_percent))

	var jumpDir: Vector2 = (arrowSprite.global_position - global_position).normalized()
	
	velocity = jumpDir * power
	
	if jumpDir.x > 0:
		animated_sprite_2d.flip_h = false # Facing Right
	elif jumpDir.x < 0:
		animated_sprite_2d.flip_h = true  # Facing Left


func _on_button_pressed() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)

	var settings = SETTINGS_SCENE.instantiate()
	canvas_layer.add_child(settings)
	get_tree().paused = true

	null
