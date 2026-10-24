extends CanvasLayer

func _process(_delta: float) -> void:
	var hovered_control = get_viewport().gui_get_hovered_control()
	if hovered_control and is_ancestor_of(hovered_control):
		Global.hovering_over_ui = true
	else:
		Global.hovering_over_ui = false
