extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrowRoot: Node2D = $jumparrowroot
@onready var arrowSprite: Sprite2D = $jumparrowroot/arrow
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var walk_sound: AudioStreamPlayer = $WalkSound

var charge_time: float = 0.0
var isJumping: bool = false
const SPEED_PEN: float = 0.05
const MIN_JUMP_POWER: float = 400.0
const MAX_JUMP_POWER: float = 600.0
const MAX_CHARGE_TIME: float = 2.0
const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0
const SETTINGS_SCENE: Resource = preload("res://assets/ui-elements/settings.tscn")

var arrowSpeed: float = -150
var jumpPower: float = 700.0

func play_footstep() -> void:
	walk_sound.play()

func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	
	# Add the gravity.
	if not is_on_floor():
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
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			charge_time += delta
			isJumping = true
			# Update animation based on how long the button is held
			if charge_time > 1.5:
				animation_player.play("charge_3")
			elif charge_time > 0.5:
				animation_player.play("charge_2")
			else:
				animation_player.play("charge_1")
		elif Input.is_action_just_released("jump") and isJumping:
			# Trigger the actual jump
			animation_player.play("jump")
			jump()
			isJumping = false
			arrowRoot.visible = false
			charge_time = 0.0 # Reset for the next jump
		else:
			isJumping = false
			charge_time = 0.0
			
			# Only play grounded animations if we aren't currently moving upward.
			if velocity.y >= 0: 
				if Input.get_axis("move_left", "move_right") != 0 or velocity.x != 0:
					animation_player.play("walk")
				else:
					animation_player.play("idle")
	else:
		isJumping = false
		charge_time = 0.0
		arrowRoot.visible = false
		
		# Add a state for rising in the air so it doesn't get stuck on previous animations.
		if velocity.y > 0:
			animation_player.play("falling")
		elif velocity.y < 0:
			animation_player.play("jump")
	
	if isJumping:
		arrowRoot.visible = true
		var val = arrowSpeed * delta
		if Input.is_action_pressed("turn_left") and not arrowRoot.global_rotation_degrees <= -170 :
			arrowRoot.global_rotation_degrees += val
		elif Input.is_action_pressed("turn_right") and not arrowRoot.global_rotation_degrees >= -10:
			arrowRoot.global_rotation_degrees -= val

# jump in the direction of the arrow
func jump() -> void:
	# Calculate the power based on charge time
	var charge_percent = clamp(charge_time / MAX_CHARGE_TIME, 0.0, 1.0)
	
	var power = abs(lerp(MIN_JUMP_POWER, MAX_JUMP_POWER, charge_percent))

	var jumpDir: Vector2 = (arrowSprite.global_position - global_position).normalized()
	
	velocity = jumpDir * power
	
	jump_sound.play()
	
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
