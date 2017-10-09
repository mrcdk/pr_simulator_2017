extends Node

signal correct
signal incorrect

enum ANSWERS {Wait, Approve, Deny}

var prs = [{
	"title": "test",
	"texts": ["- It's a test."],
	"can_merge": ANSWERS.Wait
	
}]

var approved_text = ["- Approved by reduz", "- Approved by Akien", "- Approved by Karoffel", "- Approved by Groudier", "- CI servers haven't exploded"]
var denied_text = ["- Not approved by reduz", "- Not approved by Akien", "- Not approved by Karoffel", "- Not approved by Groudier",  "- CI servers have exploded"]
var wait_text = ["- CI servers are still working", "- Reduz is thinking about it", "- Akien is thinking about it", "- Karoffel is thinking about it", "- Groudier is thinking about it" ]

var score
var open_prs
var closed_prs

func get_random(array):
	randomize()
	return array[int(rand_range(0, array.size()))]
	
func get_n_random(array, n):
	randomize()
	var input = array.duplicate()
	var r = []
	for i in range(0, n):
		var rand = int(rand_range(0, input.size()))
		r.append(input[rand])
		input.remove(rand)
		
	
	return r


func get_topmost_node(children, body):
	var pickables = children
	pickables.sort_custom(self, "sort_top_to_bottom")
	for obj in pickables:
		if !obj.has_node("area"): continue;
		var area = obj.get_node("area")
		if area.overlaps_body(body): return obj;

func sort_top_to_bottom(a, b):
	return a.get_position_in_parent() > b.get_position_in_parent()
