extends GridContainer

var prop_dir : String = "res://game/props/"
@export var column_max_length: int = 8
@export_file("*.tscn") var item_button_scene: String

func _ready() -> void:
	for prop_file in ResourceLoader.list_directory(prop_dir):
		if not prop_file.ends_with(".tscn"):
			continue
		var path := prop_dir.path_join(prop_file)
		var button_child_packed = load(item_button_scene) as PackedScene
		var button_child = button_child_packed.instantiate()
		button_child.spawned_item_path = path
		add_child(button_child)
		
	
