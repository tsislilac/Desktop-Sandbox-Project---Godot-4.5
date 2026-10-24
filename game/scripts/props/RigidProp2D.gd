extends RigidBody2D


@export_category("Physics Override")
@export() var consistent_mass : bool = true
@export var size : float = 1.0
@export var collision_container: Node2D
@export var sprite_container: Node2D
var default_debug_color: Color = Color()
var spring: DampedSpringJoint2D

var is_interacting := false
var hover := false
var smooth := false

func _ready() -> void:
	#default_debug_color = $CollisionPolygon2D.debug_color
	mouse_entered.connect(enter)
	mouse_exited.connect(exit)
	
	if consistent_mass:
		mass *= size
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Lclick"):
		if hover and not is_interacting:
			is_interacting = true
	
	if event.is_action_released("Lclick"):
		is_interacting = false
		smooth = false
	
	if event.is_action_pressed("smooth move"):
		if is_interacting:
			smooth = true
	
	if event.is_action_released("smooth move"):
		smooth = false

func _process(_delta: float) -> void:
	#coloring
	#if is_interacting:
		#$CollisionShape2D.debug_color = Color("0000ff6b")
	#elif hover:
		#$CollisionShape2D.debug_color = Color("ff00006b")
	#else:
		#$CollisionShape2D.debug_color = default_debug_color
	
	lock_rotation = smooth
		
	
	if is_interacting:
				
		if spring==null:
			var global_mouse = get_tree().get_first_node_in_group("mouse")
			spring = DampedSpringJoint2D.new()
			add_child(spring)
			
			spring.position = to_local(get_global_mouse_position())
			var spring_properties: Vector4 = Global.mouse_spring
			spring.damping=spring_properties.x
			spring.length=spring_properties.y
			spring.rest_length=spring_properties.z
			spring.stiffness=spring_properties.w
			
			spring.node_a = global_mouse.get_path()
			spring.node_b = get_path()
	else:
		if spring != null:
			spring.queue_free()
			spring=null
	
func _scale(vec: Vector2):
	collision_container.scale *= size*vec
	sprite_container.scale *= size*vec

func enter() -> void:
	hover = true
func exit() -> void:
	hover = false
