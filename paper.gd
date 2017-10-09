extends RigidBody2D

signal picked
signal released

signal destroyed(layer)

var hold_offset = Vector2()
var is_held = false

var correct_answer = globals.ANSWERS.Wait
var is_correct = false

var content = null

func _ready():
	randomize()
	set_process_input(true)
	self.linear_velocity.x = rand_range(50, 100) * sign(rand_range(-1, 1))
	self.linear_velocity.y = rand_range(50, 100) * sign(rand_range(-1, 1))
	self.angular_velocity = rand_range(10, 20) * sign(rand_range(-1, 1))
	$shadow.visible = false
	
	content = globals.prs[randi() % globals.prs.size()]
	
	correct_answer = content.can_merge
	
	if correct_answer == globals.ANSWERS.Wait:
		$timer.wait_time = rand_range(5, 15)
		$timer.start()
	
	_fill_text()
	
func _fill_text():
	var text = content.title
	text += "\n"
	for t in content.texts:
		text += "\n%s" % t
		
	$rich_text_label.bbcode_text = text
	
func set_cull_mask(i):
	$mask.range_item_cull_mask = i

func get_cull_mask():
	return $mask.range_item_cull_mask
	
func _physics_process(delta):
	$shadow.visible = is_held
	if is_held:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
	if $shadow.visible:
		$shadow.global_transform = global_transform
		$shadow.global_position.x += 15
		$shadow.global_position.y += 15
	
func _integrate_forces(state):
	var lvel = state.get_linear_velocity()
	if is_held:
		lvel = (get_global_mouse_position() - global_position + hold_offset) * 4
	
	state.set_linear_velocity(lvel)

func stamp( node, stamp_texture ):	
	if $yes_area.overlaps_body(node) && node.is_in_group("accept"): 
		if correct_answer == globals.ANSWERS.Approve: is_correct = true;
		self.collision_mask = pow(2, 3)
	elif $no_area.overlaps_body(node) && node.is_in_group("deny"): 
		if correct_answer == globals.ANSWERS.Deny: is_correct = true;
		self.collision_mask = pow(2, 4)
		
	var g_transform = node.global_transform
	var stamp = Sprite.new()
	$stamps.add_child(stamp)
	stamp.light_mask = $mask.range_item_cull_mask
	stamp.position = $stamps.to_local(g_transform.get_origin())
	stamp.rotation = g_transform.get_rotation() - $stamps.global_transform.get_rotation()
	stamp.texture = stamp_texture


func _on_paper_released():
	is_held = false

func _on_paper_picked():
	is_held = true


func _on_visibility_screen_exited():
	if is_correct:
		globals.emit_signal("correct")
	else:
		globals.emit_signal("incorrect")
	emit_signal("destroyed", get_cull_mask())
	queue_free()
	pass # replace with function body


func _on_timer_timeout():
	if randi()%2 == 0:
		content.texts[content.texts.size() - 1] = "[color=green]%s[/color]" % globals.get_random(globals.approved_text)
		correct_answer = globals.ANSWERS.Approve
	else:
		content.texts[content.texts.size() - 1] = "[color=red]%s[/color]" % globals.get_random(globals.denied_text)
		correct_answer = globals.ANSWERS.Deny
		
	_fill_text()
