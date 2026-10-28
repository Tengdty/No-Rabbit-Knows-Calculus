## The base class that allows accessories to have unique
## abilities tied to player functions
class_name AccessoryAbility
extends Node

var player: Player

## TODO called when equipped
func on_equip() -> void:
	pass
	
## TODO called when unequipped
func on_unequip() -> void:
	pass
	
## TODO called when jumping
## charge_percent: 0.0 to 1.0
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	pass
	
## TODO called when landing
func on_land() -> void:
	pass
	
## TODO called when walking (direction != 0)
func on_walk(dir: float) -> void:
	pass
