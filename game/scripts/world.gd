extends Node2D

var scalar : int = 1
@export var fullview := true
@export var debug_draw := false
@export var inset : int = 0
var walls: StaticBody2D
var prev_adjusted_size : Vector2i = Vector2i.ZERO
var prev_window_pos : Vector2i = Vector2i.ZERO




func _ready() -> void:
	
	if !fullview:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_size(Global.default_windowed_size)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_EXTEND_TO_TITLE, true)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_size(DisplayServer.screen_get_size()-Vector2i.ONE)
		
	DisplayServer.window_set_position(Vector2i.ZERO)
	
	var current_size = get_window().size
	get_tree().root.size_changed.connect(_resized)
	walls = StaticBody2D.new()
	add_child(walls)
	
	prev_adjusted_size = current_size/scalar
	prev_window_pos = get_window().position
	_resized()
	
	
func _create_box(size: Vector2i) -> void:
	var thickness := 100
	
	# parent, x,y, width,height
	@warning_ignore("integer_division") #as long as thickness is even this should be fine
	_add_wall(walls, -thickness/2+inset      , size.y/2                , thickness         , size.y+2*thickness)
	@warning_ignore("integer_division")
	_add_wall(walls, size.x+thickness/2-inset, size.y/2                , thickness         , size.y+2*thickness)
	@warning_ignore("integer_division")
	_add_wall(walls, size.x/2                , -thickness/2+inset      , size.x+2*thickness, thickness         )
	@warning_ignore("integer_division")
	_add_wall(walls, size.x/2                , size.y+thickness/2-inset, size.x+2*thickness, thickness         )
		
	#print(get_window().size)
	#print(DisplayServer.screen_get_size())

func _add_wall(parent:StaticBody2D, x:int, y:int, width:int, height:int) -> void:
	var coll := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width,height)
	coll.shape = shape
	coll.position = Vector2(x,y)
	parent.add_child(coll)
	#print(coll.position)
	#print(coll.shape.size)
	#print()
	
func _resized():
	var current_size = get_window().size
	var adjusted_size = current_size/scalar
	var size_shift = adjusted_size - prev_adjusted_size
	
	var curr_window_pos = get_window().position
	var pos_shift = curr_window_pos - prev_window_pos
	
	if pos_shift != Vector2i.ZERO or size_shift != Vector2i.ZERO:
		#var new_win_pos = get_window().position 
		for child in $PropHolder.get_children():
			if child.is_in_group("props"):
				if child is RigidBody2D:
					child.global_position -= Vector2(pos_shift)
					child.global_position.x = clamp(child.global_position.x,inset, adjusted_size.x-inset)
					child.global_position.y = clamp(child.global_position.y,inset, adjusted_size.y-inset)
					#child.linear_velocity = Vector2.ZERO
				else:
					pass
					#child.position += Vector2(size_shift)
				
	prev_adjusted_size = adjusted_size
	prev_window_pos = curr_window_pos
	
	for child in walls.get_children():
		child.free()
	
	get_window().content_scale_size = adjusted_size
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	
	_create_box(adjusted_size)

func _on_cancel_item_spawn():
	var preview := $ItemPreview
	preview._deactivate()

func _on_request_item_spawn(obj_scene: PackedScene) -> void:
	var preview := $ItemPreview
	preview._activate(obj_scene)

func _item_spawn(obj_scene: PackedScene, location: Vector2, size: Vector2, new_rotation: float) -> void:
	var obj := obj_scene.instantiate()
	if obj==null:
		push_error("object dont exist mf")
		return
	if obj is Node2D:
		obj.position = location
		obj._scale(size)
		obj.rotation = new_rotation
	$PropHolder.add_child(obj)
	
	
