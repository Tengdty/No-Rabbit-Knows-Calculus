extends Node

class_name PlayerStats

# fired whenever stats change.
signal statsChanged

var baseStats: Dictionary = {
	"speed_pen": 0.05,			# horizontal movement speed while charging jump
	"min_jump_power": 400,		# minimum jump power
	"max_jump_power": 600,		# maximum jump power
	"max_charge_time": 2,		# charge time for max jump power
	"speed": 300,				# horizontal movement speed
	"arrowspeed": 150			# directional arrow rotation speed
}

# stats granted by accessories
var accessoryStats: Dictionary = {}

var stats: Dictionary = {}

func _ready() -> void:
	recalculateStats()
	
func recalculateStats() -> void:
	stats = baseStats.duplicate(true)
	
	for stat_name in accessoryStats:
		stats[stat_name] += accessoryStats[stat_name]
	
	statsChanged.emit()
	
func setAccessoryStats(bonuses: Dictionary) -> void:
	accessoryStats = bonuses.duplicate(true)
	

# return specified stat in stats, -1 if not found
func get_stat(statName: StringName) -> float:
	return stats.get(statName, -1)
