class_name GlideAbility
extends AccessoryAbility	

## start hacking
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	
	await get_tree().create_timer(0.5).timeout
	
	player.jump_sound.play()
	player.velocity.x += jumpDir.x * clamp(charge_percent, 0.2, 0.6)  * 500
	player.velocity.y += jumpDir.y * charge_percent * 600
