extends Sprite2D

var default_image : Texture2D = Global.default_texture
@export_range(0.0,1.0) var op: float = 0.5
@export var size_bounds: Vector2 = Vector2(0.01,2.0)
var item_spawning_scene: PackedScene
var size: float = Global.default_scale
var h_flip: bool = false
var scale_size: float = 10.0
var rot: float = 0.0
var rot_degree: float = 30.0

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("cancel"):
			Global.selected_ui_button = null
			_deactivate()
			
		if event.is_action_pressed("inc_size"):
			size += scale_size * get_process_delta_time() * (int(Input.is_action_pressed("speed mod"))+1)
		elif event.is_action_pressed("dec_size"):
			size -= scale_size * get_process_delta_time() * (int(Input.is_action_pressed("speed mod"))+1)
		if event.is_action_pressed("Rclick"):
			h_flip = !h_flip
			flip_h = h_flip
		if event.is_action_pressed("Lclick"):
			if not Global.hovering_over_ui:
				var world := get_parent()
				var x_scale: float = -1.0 if h_flip else 1.0
				world._item_spawn(item_spawning_scene,position, Vector2(size*x_scale,size), rot)

func _ready() -> void:
	size_bounds *= Global.default_scale
	_deactivate()
	modulate.a = op

func _process(_delta: float) -> void:
	
	if visible and not Global.hovering_over_ui:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_pressed("rotate left"):
			rot -= deg_to_rad(rot_degree) * get_process_delta_time() * (int(Input.is_action_pressed("speed mod"))+1)
	elif Input.is_action_pressed("rotate right"):
		rot += deg_to_rad(rot_degree) * get_process_delta_time() * (int(Input.is_action_pressed("speed mod"))+1)
	
	size = clamp(size, size_bounds.x,size_bounds.y)
	scale = Vector2(size,size)/Global.preview_resolution * (1/(1-Global.default_preview_img_padding/100.0))
	rotation = rot
	position = get_global_mouse_position()

func _deactivate():
	item_spawning_scene = null
	size=Global.default_scale
	if Global.selected_ui_button != null:
		Global.selected_ui_button._on_pressed()
		Global.selected_ui_button = null
	visible = false
	rot = 0.0
	rotation = 0.0
	h_flip = false
	flip_h = false
	texture=default_image

func _activate(scene_obj: PackedScene):
	rot = 0.0
	rotation = 0.0
	h_flip = false
	flip_h = false
	size= Global.default_scale
	visible = true
	item_spawning_scene = scene_obj
	set_preview_texture()

func set_preview_texture():
	texture = await Global.get_preview_texture(item_spawning_scene)
