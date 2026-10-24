extends Button

var spawned_object_path: String
@export var parent : PanelContainer
var selected: bool = false

signal request_item_spawn(scene : PackedScene)
signal cancel_item_spawn()

func _ready() -> void:
	spawned_object_path = parent.spawned_item_path
	pressed.connect(_on_pressed)
	var world = get_parent()
	while(world.name!="world" and world is not Node2D):
		world = world.get_parent()
	connect("request_item_spawn", world._on_request_item_spawn)
	connect("cancel_item_spawn", world._on_cancel_item_spawn)

func _process(_delta: float) -> void:
	if Global.selected_ui_button!=self:
		selected=false

func _on_pressed() -> void:
	selected = !selected
	if selected:
		Global.selected_ui_button = self
		var obj_packed := load(spawned_object_path) as PackedScene
		if obj_packed==null:
			push_error("dumbass really didnt give an object to spawn")
			return
		request_item_spawn.emit(obj_packed)
	else:
		if Global.selected_ui_button==self:
			Global.selected_ui_button = null
		cancel_item_spawn.emit()
	
