extends StaticBody2D

func _ready() -> void:
	var size = 1.0
	$CollisionShape2D.scale = Vector2(size, size)

func _process(_delta: float) -> void:
	position = get_global_mouse_position()
