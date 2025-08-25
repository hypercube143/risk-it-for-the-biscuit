extends Control

@onready var itemframescene = preload("res://scenes/itemframe.tscn")
@onready var gridcontainer = $ScrollContainer/GridContainer
@onready var scrollcontainer = $ScrollContainer

func _ready() -> void:
	# display cookies in shop as 'item frames' by iterating though shop data
	# add item frames to gridcontainer
	# connect each item frame's buy button with function here
	for shop_key in Global.shopdat:
		var bundle_data = Global.shopdat[shop_key]
		var item_frame = itemframescene.instantiate()
		var name_label = item_frame.get_child(2)
		var buy_button = item_frame.get_child(5)
		var items_label = item_frame.get_child(4)
		
		item_frame.position = Vector2(60,60)
		#gridcontainer.scale = Vector2(2,2)
		scrollcontainer.scale = Vector2(2,2)
		
		name_label.text = bundle_data['name']
		buy_button.text = str(int(bundle_data['price']))
		var item_frame_desc_str = ""
		for item in bundle_data['items']:
			var cookie = Global.cookiedat[item['id']]
			item_frame_desc_str += str(int(item['count'])) + "x " + cookie['name'] + "\n"
		items_label.text = item_frame_desc_str
		
		item_frame.bundle_id = shop_key
		item_frame.item_frame_buy_button_pressed.connect(on_attempted_purchase)
		
		gridcontainer.add_child(item_frame)
		
func on_attempted_purchase(bundle_id):
	print("clicked " + bundle_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
