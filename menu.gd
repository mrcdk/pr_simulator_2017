extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	randomize()
	$v_box_container/start_game.disabled = true
	$v_box_container/start_game.text = "Loading..."
	$http_request.request("https://api.github.com/repos/godotengine/godot/pulls")
	pass

func _on_start_game_pressed():
	get_tree().change_scene("res://main.tscn")


func _on_quit_game_pressed():
	get_tree().quit()


func _on_http_request_request_completed( result, response_code, headers, body ):
	if result == HTTPRequest.RESULT_SUCCESS:
		globals.prs = []
		$v_box_container/start_game.disabled = false
		$v_box_container/start_game.text = "Start game"
		var json = parse_json( body.get_string_from_utf8() )
		for v in json:
			var can_merge = randi()%3
			var texts = []
			match can_merge:
				globals.ANSWERS.Wait:
					for v in globals.get_n_random(globals.approved_text, 2):
						texts.append("[color=green]%s[/color]" % v)
					texts.append("[color=#FFA500]%s[/color]" % globals.get_random(globals.wait_text))
				globals.ANSWERS.Approve:
					for v in globals.get_n_random(globals.approved_text, 2):
						texts.append("[color=green]%s[/color]" % v)
				globals.ANSWERS.Deny:
					for v in globals.get_n_random(globals.denied_text, 2):
						texts.append("[color=red]%s[/color]" % v)
			globals.prs.append({
				"title": v.title,
				"can_merge": can_merge,
				"texts": texts
			})
		
