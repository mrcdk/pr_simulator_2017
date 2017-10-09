extends RigidBody2D

signal stamped
signal picked
signal released

var is_held = false

export (Texture) var icon_texture = null


func _ready():
	set_process_input(true)
	$shadow.visible = false
	$sprite.texture = icon_texture
	pass

func _integrate_forces(state):
	$shadow.visible = is_held
	if is_held:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
	if $shadow.visible:
		$shadow.global_transform = global_transform
		$shadow.global_position.x += 10
		$shadow.global_position.y += 10

func _input(event):
	"""
	if event is InputEventMouseButton and event.button_index == 1 and !event.pressed:
		is_held = false
		
	# don't hold it anymore if the mouse goes outside the viewport size
	if is_held and event is InputEventMouseMotion:
		var mpos = get_global_mouse_position()
		if not get_viewport_rect().has_point(mpos):
			is_held = false
		
	"""
	if is_held and event.is_action_pressed("stamp"):
		#var obj = globals.get_topmost_node(get_parent().get_children(), self)
		var children = get_parent().get_children()
		children.remove(children.find(self))
		children.sort_custom(globals, "sort_top_to_bottom")
		for child in children:
			if child.get_node("area").overlaps_body(self):
				child.stamp(self, $sprite.texture)
				break;
		emit_signal("stamped")
		var dir = get_linear_velocity().normalized()
		apply_impulse(Vector2(), Vector2(rand_range(200, 400), rand_range(200, 400)) * dir)
		is_held = false


func _on_stamp_released():
	is_held = false

func _on_stamp_picked():
	is_held = true
