extends Control

signal shopgui_close_button_pressed

@onready var itemframescene = preload("res://scenes/itemframe.tscn")
@onready var gridcontainer = $ScrollContainer/GridContainer
@onready var scrollcontainer = $ScrollContainer
@onready var cookiebalancelabel = $cookie_balance

@onready var roulettewheel = $roulettewheel

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
		var icon_texture_rect = item_frame.get_child(1)
		
		#icon_texture_rect.texture = load(Global.shopdat[shop_key]['icon'])
		icon_texture_rect.scale = Vector2(0.25,0.25)
		
		item_frame.position = Vector2(60,60)
		#gridcontainer.scale = Vector2(2,2)
		scrollcontainer.scale = Vector2(2,2)
		
		name_label.text = bundle_data['name']
		buy_button.text = str(int(bundle_data['price']))
		var item_frame_desc_str = ""
		var x_mod = 50
		var y_mod = 100
		for item in bundle_data['items']:
			var cookie = Global.cookiedat[item['id']]
			item_frame_desc_str += str(int(item['count'])) + "x " + cookie['name'] + "\n"
			var sprite2d = Sprite2D.new()
			sprite2d.texture = load(cookie['icon'])
			sprite2d.scale = Vector2(0.5, 0.5)
			sprite2d.position = Vector2(x_mod, y_mod)
			icon_texture_rect.add_child(sprite2d)
			x_mod += 150
			y_mod += 75
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
	
	roulettewheel.update_wheel()
		
	
func update_buttons():
	# make any itemframe that costs more than what the player has unpurchasable by disabling buttons
	for item_frame in item_frames:
		var button = item_frame.get_child(5)
		if int(button.text) <= Global.cookie_balance:
			button.disabled = false
		else:
			button.disabled = true
	# update cookie_balance label too :p this is the only place it needs to update
	cookiebalancelabel.text = str(int(Global.cookie_balance))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_button_pressed() -> void:
	emit_signal("shopgui_close_button_pressed")
