## The class mostly relating to player movement and control
class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrowRoot: Node2D = $jumparrowroot
@onready var arrowSprite: Sprite2D = $jumparrowroot/arrow
@onready var playerStats: PlayerStats = $PlayerStats
@onready var equipment_manager: EquipmentManager = $EquipmentManager

## Used in on_land() in AccessoryAbility
var was_on_floor: bool = false

var charge_time: float = 0.0
var isJumping: bool = false

var speed_pen: float = 0.05
var min_jump_power: float = 400.0
var max_jump_power: float = 600.0
var max_charge_time: float = 2
var speed: float = 300.0

const JUMP_VELOCITY: float = -400.0
const SETTINGS_SCENE: Resource = preload("res://assets/ui-elements/settings.tscn")

# the rotation amount the arrow change
var arrow_speed: float = -150
var jumpPower: float = 700.0

## set stats from playerStats
func setStats() -> void:
	speed_pen = 		playerStats.get_stat(&"speed_pen")
	min_jump_power = 	playerStats.get_stat(&"min_jump_power")
	max_jump_power = 	playerStats.get_stat(&"max_jump_power")
	max_charge_time = 	playerStats.get_stat(&"max_charge_time")
	speed = 			playerStats.get_stat(&"speed")
	arrow_speed = 		playerStats.get_stat(&"arrow_speed")

# initalize all stats using PlayerStats
func _ready() -> void:
	setStats()
	
	# holy roblox knowledge coming in clutch here.
	playerStats.stats_changed.connect(func():
		setStats()
		print("player stats changed, :eyes:")
		)

func _physics_process(delta: float) -> void:
	# saving this variable since its reused
	var onFloor: bool = is_on_floor()
	var direction: float = 0.0
	
	# runs on the frame that the player lands
	if not was_on_floor and onFloor:
		equipment_manager.on_land()
	
	# Add the gravity.
	if not onFloor:
		velocity += get_gravity() * delta
	else:
		# Only check for left/right input if we are on the ground
		direction = Input.get_axis("move_left", "move_right")
		
		if direction and not isJumping:
			velocity.x = direction * speed
		elif direction and isJumping:
			velocity.x = direction * speed * speed_pen
		else:
			# this is essentially friction to your horizontal speed.
			velocity.x = move_toward(velocity.x, 0, speed/3)

		# Change direction the sprite is facing (Only update while walking)
		if not isJumping:
			if direction > 0.0:
				animated_sprite_2d.flip_h = false
			elif direction < 0.0:
				animated_sprite_2d.flip_h = true

	move_and_slide()
	
	was_on_floor = is_on_floor()

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
		var val = arrow_speed * delta
		if Input.is_action_pressed("turn_left") and not arrowRoot.global_rotation_degrees - val <= -170 :
			arrowRoot.global_rotation_degrees += val
		elif Input.is_action_pressed("turn_right") and not arrowRoot.global_rotation_degrees + val >= -10:
			arrowRoot.global_rotation_degrees -= val

# jump in the direction of the arrow
func jump() -> void:
	# Calculate the power based on charge time
	var charge_percent = clamp(charge_time / max_charge_time, 0.0, 1.0)
	
	var power = abs(lerp(min_jump_power, max_jump_power, charge_percent))

	var jumpDir: Vector2 = (arrowSprite.global_position - global_position).normalized()
	
	equipment_manager.on_jump(charge_percent, jumpDir)
	
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
