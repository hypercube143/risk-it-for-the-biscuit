extends Node

var cookiedat
var shopdat

var cookie_balance = 0

var cookie_inventory = {}

func _ready() -> void:
	# load cookie and shop dat
	var cookiedat_f = FileAccess.open("res://scripts/cookiedat.json", FileAccess.READ)
	var shopdat_f = FileAccess.open("res://scripts/shopdat.json", FileAccess.READ)
	cookiedat = JSON.parse_string(cookiedat_f.get_as_text())
	shopdat = JSON.parse_string(shopdat_f.get_as_text())
	cookiedat_f.close()
	shopdat_f.close()
	
	# fake items for testing REMOVE THIS LATER
	for i in range(1, 20):
		var d = shopdat['1'].duplicate()
		d['name'] = str(int(i))
		shopdat[str(int(i))] = d


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
