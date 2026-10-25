class_name AccessoryPickup
extends Area2D

@export var accessory1: AccessoryData
@export var accessory2: AccessoryData

var collected: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("ayoooo")
	if collected:
		return
	
	if not body is Player:
		print("suspicious", body, "detected")
		return
		
	if not accessory1 or not accessory2:
		return
		
	var equipment_manager = body.get_node("EquipmentManager")
	
	equipment_manager.equip(0, accessory1)
	equipment_manager.equip(1, accessory2)
	
	collected = true
	
	#deletion
	queue_free()
