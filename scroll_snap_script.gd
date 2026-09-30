extends ScrollContainer

@export var threshold: float = 20.0
@export var snap_animation: float = 0.25

var _tween: Tween
var _page_index: int = 0
var _drag_start: float = 0.0
var _is_dragging: bool = false

func _ready() -> void:
	scroll_started.connect(_on_scroll_started)
	scroll_ended.connect(_on_scroll_ended)
	gui_input.connect(_on_gui_input)

func _on_scroll_started() -> void:
	_is_dragging = true
	_kill_tween()
	_drag_start = scroll_horizontal

func _on_scroll_ended() -> void:
	_is_dragging = false
	var delta := scroll_horizontal - _drag_start
	var target := _page_index
	if absf(delta) >= threshold:
		target += 1 if delta > 0 else -1
	_go_to_page(target)

func _on_gui_input(event: InputEvent) -> void:
	if _is_dragging:
		return
	if event is InputEventMouseButton and event.pressed:
		var step := 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_RIGHT:
				step = 1
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_LEFT:
				step = -1
		if step != 0:
			accept_event() 
			if _tween == null or not _tween.is_running():
				_go_to_page(_page_index + step)

func _go_to_page(index: int) -> void:
	if get_child_count() == 0:
		return
	var pages: Array = get_child(0).get_children().filter(
		func(c): return c is Control and c.visible)
	if pages.is_empty():
		return

	_page_index = clampi(index, 0, pages.size() - 1)
	var target: float = pages[_page_index].position.x

	_kill_tween()
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scroll_horizontal", int(target), snap_animation)

func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
