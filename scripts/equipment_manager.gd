class_name EquipmentManager

extends Node

## called whenever accessory is equipped or unequipped
signal equipment_changed

@export var player_stats: PlayerStats

## abilities that are currently active
var active_abilities: Dictionary = {}

# its like you?? why did i write this
## int (0, 1) because you can only wear 2 at a time.
var equipped: Dictionary[int, AccessoryData]

## equip an accessory
func equip(slot: int, accessory: AccessoryData) -> void:
	
	if accessory == null:
		push_error("Passed accessory is null")
		return
	
	# we don't want to emit on unequip when we'll do it anyways in this function
	unequip(slot, false)
	
	equipped[slot] = accessory
	
	# add abilities
	add_abilities(slot, accessory)
	
	# refresh abilities and stats
	recalculate_equipment_stats()
	
	equipment_changed.emit()
	
## returns 1 if successful, returns 0 if nothing was there
func unequip(slot: int, shouldEmit: bool = true) -> int:
	if not equipped.has(slot):
		return 0
		
	equipped.erase(slot)
	
	# remove abilities as well
	remove_abilities(slot)
	
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

# accessory functions
## add an accessory's ability/abilities to the active_abilities dictionary
func add_abilities(slot: int, accessory: AccessoryData) -> void:
	
	# every key in the dictionary points to an array of AccessoryAbility
	active_abilities[slot] = []
	
	for scene: PackedScene in accessory.abilities:
		print("added new ability")
		var ability: AccessoryAbility = scene.instantiate()
		# not sure if this works since it returns a Node.
		ability.player = get_parent()
		add_child(ability)
		ability.on_equip()
		active_abilities[slot].append(ability)
	
## remove all abilties associated with a slot	
func remove_abilities(slot: int) -> void:
	if not active_abilities.has(slot):
		push_warning("active_abilities does not have slot", slot)
		return
		
	for ability: AccessoryAbility in active_abilities[slot]:
		ability.on_unequip()
		# lowk not sure if on_unequip will work before its deleted
		# depends on how long queue takes
		ability.queue_free()
		
	active_abilities.erase(slot)

# following are called dispatch functions supposedly.
# just allows for compiler support.
	
## called when space is initially pressed
func on_start_jump() -> void:
	for slot: int in active_abilities:
		for ability: AccessoryAbility in active_abilities[slot]:
			ability.on_start_jump()
	
## when player jumps
func on_jump(charge_percent: float, jumpDir: Vector2) -> void:
	for slot: int in active_abilities:
		for ability: AccessoryAbility in active_abilities[slot]:
			ability.on_jump(charge_percent, jumpDir)
	
## when landing
func on_land() -> void:
	for slot: int in active_abilities:
		for ability: AccessoryAbility in active_abilities[slot]:
			ability.on_land()
	
## when walking (direction != 0)
func on_walk(dir: float) -> void:
	for slot: int in active_abilities:
		for ability: AccessoryAbility in active_abilities[slot]:
			ability.on_walk(dir)
