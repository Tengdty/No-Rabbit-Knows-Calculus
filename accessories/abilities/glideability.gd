class_name GlideAbility
extends AccessoryAbility


## start hacking
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	
	await get_tree().create_timer(0.5).timeout
	
	player.velocity.y += -300
