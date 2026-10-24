extends Node

@export var preview_resolution: int = 2

# Damp, Length, Rest Length, Stiffness
@export var mouse_spring : Vector4 = Vector4(0.25, 0.0, 0.0, 50.0)

@export var default_windowed_size: Vector2i = Vector2i(1080,1080)

@export var default_scale: float = 0.5

@export var default_texture: Texture2D = load("res://game/resources/sprites/300px-Debugempty.png")

@export var default_preview_img_padding: float = 10.0

var preview_texture_dictionary: Dictionary[String, Texture2D] = {}

var selected_ui_button: Button

var hovering_over_ui: bool  = false

# vars  ^^^
# funcs VVV

func get_max_distance_from_center(root: Node) -> float:
	var max_dist: float = 64.0
	#indexes are [node selected, their transform]
	var sub_nodes: Array = [[root, Transform2D()]]
	
	while sub_nodes.size() > 0:
		var item = sub_nodes.pop_back()
		var node: Node = item[0]
		var parent_transform: Transform2D = item[1]
		
		if node is Node2D:
			var local_transform = parent_transform*node.transform
			
			if node is Sprite2D and node.texture:
				var half_point = node.texture.get_size()/2.0
				for corner in [Vector2(-half_point.x,-half_point.y),Vector2(half_point.x,half_point.y)]:
					var point = local_transform*corner
					max_dist = max(max_dist,abs(point.x),abs(point.y))
					
			for child in node.get_children():
				sub_nodes.push_back([child, local_transform])
	
	return max_dist

func generate_scene_preview(scene: PackedScene, camera_size: Vector2i = Vector2i(128,128)) -> Texture2D:
	var previewed_scene = scene.instantiate()
	#if previewed_scene.has_method("_scale"):
		#previewed_scene._scale(Vector2(Global.default_scale,Global.default_scale)*Global.preview_resolution)
	
	var rad = Global.get_max_distance_from_center(previewed_scene)
	
	var viewport = SubViewport.new()
	viewport.size = Vector2i(camera_size*Global.preview_resolution)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	viewport.add_child(previewed_scene)
	get_tree().root.add_child.call_deferred(viewport)
	
	var half_viewport = Vector2(viewport.size)/2.0
	var zoom = (half_viewport.x / rad) * (1 - Global.default_preview_img_padding/100.0)
	
	var center_cam := Transform2D()
	center_cam = center_cam.scaled(Vector2(zoom,zoom))
	center_cam.origin = Vector2(camera_size*Global.preview_resolution)/2
	viewport.set_deferred("canvas_transform", center_cam)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var preview_img := viewport.get_texture().get_image()
	viewport.queue_free()
	
	return ImageTexture.create_from_image(preview_img)

func get_scene_key(scene: PackedScene) -> String:
	var path: String = scene.resource_path.get_file().get_basename()
	if path.begins_with("rp_"):
		path = path.erase(0,3)
	return path

func get_preview_texture(scene: PackedScene) -> Texture2D:
	var temp_obj = scene.instantiate()
	var key: String = get_scene_key(scene)
	if Global.preview_texture_dictionary.has(key):
		temp_obj.queue_free()
		return Global.preview_texture_dictionary.get(key)
	else:
		var preview_texture: Texture2D = await Global.generate_scene_preview(scene)
		Global.preview_texture_dictionary[key] = preview_texture
		temp_obj.queue_free()
		return preview_texture
