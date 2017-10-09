extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$score.text = "Score: %s" % globals.score
	$open_pr.text = "Pull Requests left open: %s" % globals.open_prs
	$closed_pr.text = "Pull Requests closed: %s" % globals.closed_prs
	pass


func _on_button_pressed():
	get_tree().change_scene("res://main.tscn")


func _on_close_pressed():
	get_tree().quit()
