class_name GlideAbility
extends AccessoryAbility	

@export var maxGlideVelocity: int = 150

## start hacking
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	
	await get_tree().create_timer(0.5).timeout
	
	if player.is_on_floor(): return
	
	# prevent glide from gaining op amount of distance
	player.velocity.x = clamp(player.velocity.x, -maxGlideVelocity, maxGlideVelocity)
	
	# this is ahh i know
	for i in range(25):
		await get_tree().create_timer(0.02).timeout
		player.velocity.y = 0
	#player.jump_sound.play()
	#player.velocity.x += jumpDir.x * clamp(charge_percent, 0.2, 0.6)  * 500
	#player.velocity.y += jumpDir.y * charge_percent * 600
