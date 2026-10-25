class_name EquipmentManager

extends Node

## called whenever accessory is equipped or unequipped
signal equipment_changed

@export var player_stats: PlayerStats
# TODO: implement ability_manager, add ability scenes, call ability methods within player.gd
@export var ability_manager: Node 

# its like you?? why did i write this
# int (0, 1) because you can only wear 2 at a time.
var equipped: Dictionary[int, AccessoryData]

## equip an accessory
func equip(slot: int, accessory: AccessoryData) -> void:
	
	if accessory == null:
		push_error("Passed accessory is null")
		return
	
	# we don't want to emit on unequip when we'll do it anyways in this function
	unequip(slot, false)
	
	equipped[slot] = accessory
	
	# refresh abilities and stats
	recalculate_equipment_stats()
	
	equipment_changed.emit()
	
## returns 1 if successful, returns 0 if nothing was there
func unequip(slot: int, shouldEmit: bool = true) -> int:
	if not equipped.has(slot):
		return 0
		
	equipped.erase(slot)
	
	recalculate_equipment_stats()
	
	if shouldEmit:
		equipment_changed.emit()
		
	
	return 1
	
func recalculate_equipment_stats() -> void:
	var combined_bonuses: Dictionary[StringName, float]
	
	for accessory: AccessoryData in equipped.values():
		
		for stat_name: StringName in accessory.accessory_stats:
			combined_bonuses[stat_name] = (
				combined_bonuses.get(stat_name, 0.0) +
				accessory.accessory_stats.get(stat_name, 0.0)
			)
	player_stats.setAccessoryStats(combined_bonuses)
		
		
	
## returns null if no accessory equipped for that slot or slot doesn't exist
func getEquipped(slot: int) -> AccessoryData:
	return equipped.get(slot, null)
