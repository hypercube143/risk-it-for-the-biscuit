extends Control

@onready var itemframescene = preload("res://scenes/itemframe.tscn")
@onready var gridcontainer = $ScrollContainer/GridContainer
@onready var scrollcontainer = $ScrollContainer
@onready var cookiebalancelabel = $cookie_balance

var item_frames = []

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
		item_frame.item_frame_buy_button_pressed.connect(on_purchase)
		
		gridcontainer.add_child(item_frame)
		item_frames.append(item_frame)
		update_buttons()
		
func on_purchase(bundle_id):
	# subtract price from player's cookie balance
	var bundle = Global.shopdat[bundle_id]
	var price = bundle['price']
	Global.cookie_balance -= price
	update_buttons()
	# add cookies to inventory
	for cookie in bundle['items']:
		if Global.cookie_inventory.has(cookie['id']):
			Global.cookie_inventory[cookie['id']] += cookie['count']
		else:
			Global.cookie_inventory[cookie['id']] = cookie['count']
	print(Global.cookie_inventory)
		
	
func update_buttons():
	# make any itemframe that costs more than what the player has unpurchasable by disabling buttons
	for item_frame in item_frames:
		var button = item_frame.get_child(5)
		if int(button.text) <= Global.cookie_balance:
			button.disabled = false
		else:
			button.disabled = true
	# update cookie_balance label too :p this is the only place it needs to update
	cookiebalancelabel.text = str(Global.cookie_balance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
