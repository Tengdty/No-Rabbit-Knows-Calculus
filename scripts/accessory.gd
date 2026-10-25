class_name AccessoryData

extends Resource

@export var item_name: String # i.e. Spring Boots
@export var description: String # i.e. Boots but there's 2 springs attached. and F = -kx, therefore the harmonic moti...
@export var texture: Texture2D

@export var accessory_stats: Dictionary[StringName, float] = {} # i.e. {&"max_jump_power": 100, &"min_jump_power": 100}
# keep in mind these stats are **additive**, they do not overwrite current stats
