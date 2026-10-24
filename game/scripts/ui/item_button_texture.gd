extends TextureRect

@export var parent : PanelContainer

func _ready() -> void:
	var obj_packed := load(parent.spawned_item_path) as PackedScene
	if obj_packed==null:
		push_error("fucked packedscene in button img")
		return
	texture = await Global.get_preview_texture(obj_packed)
