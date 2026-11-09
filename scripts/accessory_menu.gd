class_name AccessoryMenu
extends CanvasLayer

# requires accessory menu to be parented under Player
@onready var equipmentManager: EquipmentManager = $"../EquipmentManager"
## contains all 9 accessories buttons
@onready var grid: GridContainer = $"CenterContainer/PanelContainer/VBoxContainer/GridContainer"
## contains the 2 equipped accessory buttons
@onready var hboxcontainer: HBoxContainer = $"CenterContainer/PanelContainer/VBoxContainer/HBoxContainer"

## accepeted values: 0 or 1
var selected_slot = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	for i: int in range(9):
		if not grid.get_child(i) or not grid.get_child(i) is Button:
			push_warning('incorrect child')
			return
		var btn: Button = grid.get_child(i)
		btn.pressed.connect(_on_accessory_pressed.bind(i))
	
	# to change the slot the accessory will equip into
	for i: int in range(2):
		if not hboxcontainer.get_child(i) or not hboxcontainer.get_child(i) is Button:
			push_warning('incorrect child')
			return
		var btn: Button = hboxcontainer.get_child(i)
		btn.pressed.connect(func():
			selected_slot = i;
			print("selected acc slot =",i,"!")
		)
	_refresh_buttons()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_accessory_menu"):
		visible = not visible
		if visible:
			_refresh_buttons()
		get_viewport().set_input_as_handled()
		
		
## refresh state of the buttons, which ones are disabled and not
func _refresh_buttons():
	for i in range(9):
		var button: Button = grid.get_child(i)
		var accessory: AccessoryData = _get_accessory_by_index(i)
		var unlocked: bool = equipmentManager.is_unlocked(accessory)

		if accessory != null:
			button.tooltip_text = accessory.description
			button.icon = accessory.texture
		button.disabled = not unlocked
		button.add_theme_color_override("icon_disabled_color", Color.BLACK)

func _on_accessory_pressed(index: int):
	var accessory: AccessoryData = _get_accessory_by_index(index)
	
	if not accessory or not equipmentManager.is_unlocked(accessory):
		return
	
	equipmentManager.equip(selected_slot, accessory)
	
	# set the image in the top
	var selectedBtn: Button = hboxcontainer.get_child(selected_slot)
	selectedBtn.icon = accessory.texture

## return the unlockable accessory using index
func _get_accessory_by_index(index: int) -> AccessoryData:
	var unlockedAccs: Array[AccessoryData] = equipmentManager.unlocked_accessories.keys()
	for i: int in unlockedAccs.size():
		if index == i:
			return unlockedAccs[i]
	return null
