## The base class that allows accessories to have unique
## abilities tied to player functions
class_name AccessoryAbility
extends Node

var player: Player

## called when equipped
func on_equip() -> void:
	pass
	
## called when unequipped
func on_unequip() -> void:
	pass
	
## called when space is initially pressed
func on_start_jump() -> void:
	pass
	
## called when jumping
## charge_percent: 0.0 to 1.0
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	pass
	
## called when landing
func on_land() -> void:
	pass
	
## called when walking (direction != 0)
func on_walk(dir: float) -> void:
	pass
