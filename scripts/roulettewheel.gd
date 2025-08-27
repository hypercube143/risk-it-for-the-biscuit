extends Control

signal cookie_choosen

@onready var wheelmaptexture = preload("res://assets/art/roulettewheelmap.png")
@onready var wheelmaptextureouter = preload("res://assets/art/roulettewheelmapouter.png")
@onready var spinnystuff = $spinnystuff
@onready var center = $spinnystuff/center # for rotating the cookie sprites around when generating wheel
@onready var cursor = $cursor

var icon_scale = 0.25
var icon_radius = 200

var result_map = []

func _ready() -> void:
	update_wheel()
		
func update_wheel():
	
	cursor.z_index = 2
	
	# cull any existing children >:D
	var children = spinnystuff.get_children()
	for child in children:
		if child.name.begins_with("progbar_") or child.name.begins_with("@TextureProgressBar"):
			child.queue_free()
	for child in center.get_children():
		if child.name.begins_with("prog_icon_") or child.name.begins_with("@Sprite2D") or child.name.begins_with("@Label"):
			child.queue_free()
			
	result_map.clear()
	
	# iterate through inventory to render ratios of each cookie count via radial progress bars
	var start_angle = 0
	var total_cookie_count = 0
	for cookie_count in Global.cookie_inventory.values():
		total_cookie_count += cookie_count
		
	var n = 0 # number of pie chart slices
	for cookie_key in Global.cookie_inventory.keys():

		var ratio: float = float(Global.cookie_inventory[cookie_key])/float(total_cookie_count)
		var percent: float = ratio * 100.0
	
		var progbar = TextureProgressBar.new()
		progbar.name = "progbar_" + str(n)
		progbar.fill_mode = TextureProgressBar.FillMode.FILL_CLOCKWISE
		progbar.texture_progress = wheelmaptexture
		progbar.texture_over = wheelmaptextureouter
		# progbar.tint_progress = Color(255,0,0) if n % 2 == 0 else Color(0,0,255) # alternate
		progbar.tint_progress = Color(Global.cookiedat[cookie_key]['wheel_colour'])
		progbar.value = percent + 0.5 # 0.5 fills gaps
		progbar.radial_initial_angle = start_angle
		progbar.position = Vector2(-256, -256)
		spinnystuff.add_child(progbar)
		
		# display icon
		var icon_texture = load(Global.cookiedat[cookie_key]['icon'])
		var icon = Sprite2D.new()
		icon.name = "prog_icon_" + str(n)
		icon.texture = icon_texture
		icon.scale = Vector2(icon_scale, icon_scale)
		icon.z_index = 1
		var mid = deg_to_rad((start_angle + (360.0 * ratio)/2)-90)
		icon.position = Vector2(icon_radius, 0).rotated(mid)
		icon.rotation = mid + PI * 0.5
		center.add_child(icon)
	
		var t = Label.new()
		t.text = "x" + str(int(Global.cookie_inventory[cookie_key]))
		t.scale = Vector2(2,2)
		t.position = Vector2(icon_radius, 0).rotated(mid)
		# t.rotation = mid # + PI * 0.5
		t.z_index = 3
		center.add_child(t)
		
		# start angle for next cookie
		var old_start_angle = start_angle
		start_angle += 360.0 * ratio
		n += 1
		
		if old_start_angle != start_angle:
			result_map.append({"start": old_start_angle, "end": start_angle, "res": cookie_key})
		
func spin_wheel():
	var angle = randf_range(360*2,360*3)
	var angle_rad = deg_to_rad(angle)
	#var angle_lobotomised = int(angle-90) % 360
	#var res
	#for range in result_map:
		#if angle_lobotomised > range['start'] and angle_lobotomised <= range['end']:
			#res = range['res']
			#break
	create_tween().tween_property(spinnystuff, "rotation", angle_rad, 3)\
	.set_trans(Tween.TRANS_CIRC)\
	.set_ease(Tween.EASE_OUT)\
	.finished.connect(on_spin_finished)
	
	for t in center.get_children():
		if t.name.begins_with("@Label"):
			create_tween().tween_property(t, "rotation", -angle_rad, 3)\
			.set_trans(Tween.TRANS_CIRC)\
			.set_ease(Tween.EASE_OUT)
	
func on_spin_finished():
	var chosen_cookie_id = pick_slice_from_cursor()
	
	# remove 1x cookie of cookie id, remove from inventory completely if now 0
	Global.cookie_inventory[chosen_cookie_id] -= 1
	if Global.cookie_inventory[chosen_cookie_id] == 0:
		Global.cookie_inventory.erase(chosen_cookie_id)
	
	var icon = Sprite2D.new()
	icon.texture = load(Global.cookiedat[chosen_cookie_id]['icon'])
	icon.z_index = 3
	icon.scale = Vector2(0, 0)
	icon.rotation = - spinnystuff.rotation
	center.add_child(icon)
	create_tween().tween_property(icon, "scale", Vector2(1, 1), 1)\
	.set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(2.0).timeout 
	create_tween().tween_property(icon, "scale", Vector2(0, 0), 1)\
	.set_trans(Tween.TRANS_BACK)\
	.finished.connect(func():
		icon.queue_free
		update_wheel()
		reset_wheel_position()
		await get_tree().create_timer(0.5).timeout
		emit_signal("cookie_choosen", chosen_cookie_id)
	)
	#update_wheel()
	
func angle_dist_deg(a, b):
	# fit into -180, 180
	var diff = fposmod(a - b + 180.0, 360.0) - 180
	return abs(diff)
	
func pick_slice_from_cursor():
	var wheel_glob = spinnystuff.global_position
	var cursor_vec = cursor.global_position
	var cursor_deg = rad_to_deg(cursor_vec.angle())
	cursor_deg = 180 # fposmod(cursor_deg, 360.0)
	
	var wheel_deg = fposmod(rad_to_deg(spinnystuff.rotation), 360.0)
	var selection_deg = fposmod(cursor_deg - wheel_deg, 360.0)
	
	for range in result_map:
		# hell
		var s = fposmod(range['start'], 360.0)
		var e = fposmod(range['end'], 360.0)
		if s > e or (s == 0 and e == 0):
			e = 360
		if s <= selection_deg and selection_deg <= e:
			return range['res']
	
	# sometimes it lands on almost the exact border between slices
	for range in result_map:
		var s = fposmod(range['start'], 360.0)
		var e = fposmod(range['end'], 360.0)
		if angle_dist_deg(selection_deg, s) <= 0.5 or angle_dist_deg(selection_deg, e) <= 0.5:
			return range['res']
			
	return null
	
func reset_wheel_position():
	create_tween().tween_property(spinnystuff, "rotation", 0, 0.5)\
		.set_trans(Tween.TRANS_CIRC)#\

func _process(delta: float) -> void:
	# for testing REMOVE LATER
	if Input.is_action_just_pressed("ui_down"):
		spin_wheel()
	if Input.is_action_just_pressed("ui_up"):
		reset_wheel_position()
