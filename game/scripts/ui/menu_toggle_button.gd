extends Button

var menu_opened: bool = false
@export var anim_t: float = 0.25
var anim_pos: float = 0.0
@export var max_parent: Control
@export var toggled_menu : Control

var target :float = -180.0
var start  :float = 0.0

func _ready() -> void:
	anim_pos = 1.0


func _process(delta: float) -> void:
	if max_parent == null:
		push_error(false, "no parent provided to ui main button")
		return
		
	
	
	if anim_pos < 1.0:
		anim_pos += delta/anim_t
		anim_pos = clamp(anim_pos,0.0,1.0)
		max_parent.rotation = lerp(deg_to_rad(start), deg_to_rad(target), anim_pos)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle menu"):
		_pressed()
		if not menu_opened and Global.selected_ui_button != null:
			Global.selected_ui_button._on_pressed()
			Global.selected_ui_button = null

func _pressed() -> void:
	menu_opened = !menu_opened
	anim_pos = 0.0
	if menu_opened:
		start = 0.0
		target = -180.0
		toggled_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		start = -180.0
		target = 0.0
		toggled_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toggled_menu.visible = menu_opened
	print(menu_opened)
	
