extends Node2D

var _gravity_direction = Vector2(0, 1)
var _max_gravity = Vector2(3, 3)

var _is_holding_something = false

var _cull_masks = []

var score = 0
var open_prs = 0
var closed_prs = 0

onready var paper_scene = preload("res://paper.tscn")

func _ready():
	randomize()
	
	for i in range(1, 32):
		_cull_masks.append({
			"layer": pow(2, i),
			"free": true
		});	
	
	$area.gravity_vec.x = rand_range(-2, 2)
	$area.gravity_vec.y = 2
	
	
	_on_gravity_timer_timeout()
	_on_paper_timer_timeout()
	
	_add_new_paper()
	_add_new_paper()
	
	set_physics_process(true)
	set_process_input(true)
	
	globals.connect("correct", self, "_on_correct")
	globals.connect("incorrect", self, "_on_incorrect")
	
	$game_timer.wait_time = 60 * 1
	
	$game_timer.start()
	
func _input(event):
	if !_is_holding_something and event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		var obj = globals.get_topmost_node($pickables.get_children(), $mouse)
		if !obj: return;
		obj.get_parent().move_child(obj, obj.get_parent().get_child_count())
		$mouse/pin.node_a = $mouse.get_path()
		$mouse/pin.node_b = obj.get_path()
		obj.emit_signal("picked")
		_is_holding_something = true
	elif _is_holding_something and event is InputEventMouseButton and event.button_index == 1 and !event.pressed:
		var obj = get_node($mouse/pin.node_b)
		$mouse/pin.node_a = NodePath()
		$mouse/pin.node_b = NodePath()
		if !obj:
			print("The pin didn't have a node_b????")
			for child in $pickables.get_children():
				child.emit_signal("released")
		else:
			obj.emit_signal("released")
			
		_is_holding_something = false
	
func _physics_process(delta):
	$area.gravity_vec.x += rand_range(0, 1) * _gravity_direction.x * delta
	$area.gravity_vec.y += rand_range(0, 1) * _gravity_direction.y * delta
	
	if abs($area.gravity_vec.x) > _max_gravity.x: _gravity_direction.x *= -1;
	if abs($area.gravity_vec.y) > _max_gravity.y: _gravity_direction.y *= -1;
	
	$mouse.move_and_collide(get_global_mouse_position() - $mouse.global_position)
	
	var elapsed = $game_timer.get_time_left()
	var minutes = elapsed / 60
	var seconds = int(elapsed) % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	
	$UI/timer_label.text = "TIME: %s" % str_elapsed

func _add_new_paper():
	print("Launching new paper")
	
	if not $new_message.playing:
		$new_message.play()
		
	open_prs += 1
	$UI/open_prs.text = "Opened PR: %s" % open_prs
	var paper = paper_scene.instance()
	$pickables.add_child(paper)
	var s = paper.get_node("sprite").texture.get_size() / 2.0
	var v = Vector2(1024, 600)
	paper.position = Vector2(rand_range(s.x, v.x-s.x), rand_range(s.y, v.y - s.y))
	paper.connect("destroyed", self, "_on_paper_destroy")
	var mask = 0
	for m in _cull_masks:
		if m.free:
			mask = m.layer
			m.free = false
			break
			
	paper.set_cull_mask(mask)

func _on_paper_timer_timeout():
	$paper_timer.wait_time = rand_range(5, 10)
	$paper_timer.start()
	
	if get_tree().get_nodes_in_group("papers").size() > 20: return;
	
	_add_new_paper()
	
func _on_paper_destroy(layer):
	for m in _cull_masks:
		if m.layer == layer:
			m.free = true
			break

func _on_gravity_timer_timeout():
	_gravity_direction = _gravity_direction.rotated(deg2rad(rand_range(0, 360)))
	$gravity_timer.wait_time = rand_range(2, 5)
	$gravity_timer.start()


func _on_stamp_stamped():
	_is_holding_something = false
	$mouse/pin.node_a = NodePath()
	$mouse/pin.node_b = NodePath()
	
func _on_correct():
	score += 100
	
	open_prs -= 1
	closed_prs += 1
	$UI/open_prs.text = "Opened PR: %s" % open_prs
	$UI/closed_prs.text = "Closed PR: %s" % closed_prs
	
	$claps.play()
	
	$UI/score.text = "Score: %s" % score
	
	
func _on_incorrect():
	score += 20
	
	open_prs -= 1
	closed_prs += 1
	$UI/open_prs.text = "Opened PR: %s" % open_prs
	$UI/closed_prs.text = "Closed PR: %s" % closed_prs
	
	$boo.play()
	
	$UI/score.text = "Score: %s" % score


func _on_game_timer_timeout():
	globals.score = score
	globals.open_prs = open_prs
	globals.closed_prs = closed_prs
	get_tree().change_scene("res://end.tscn")
	print("THE END")
