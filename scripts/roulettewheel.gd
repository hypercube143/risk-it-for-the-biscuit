extends Control

@onready var wheelmaptexture = preload("res://assets/art/roulettewheelmap.png")
@onready var center = $center # for rotating the cookie sprites around when generating wheel

var icon_scale = 0.25
var icon_radius = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_wheel()
		
func update_wheel():
	
	# cull any existing children >:D
	var children = self.get_children()
	for child in children:
		if child.name.begins_with("progbar_"):
			child.queue_free()
	
	# iterate through inventory to render ratios of each cookie count via radial progress bars
	var start_angle = 0
	var total_cookie_count = 0
	for cookie_count in Global.cookie_inventory.values():
		total_cookie_count += cookie_count
		
	var n = 0 # number of pie chart slices
	for cookie_key in Global.cookie_inventory.keys():

		var ratio = float(Global.cookie_inventory[cookie_key])/float(total_cookie_count)
		var percent = ratio * 100
	
		var progbar = TextureProgressBar.new()
		progbar.fill_mode = TextureProgressBar.FillMode.FILL_CLOCKWISE
		progbar.texture_progress = wheelmaptexture
		progbar.tint_progress = Color(255,0,0) if n % 2 == 0 else Color(0,0,255) # alternate
		progbar.value = percent
		progbar.radial_initial_angle = start_angle
		progbar.name = "progbar_" + str(n)
		add_child(progbar)
		
		# display icon
		var icon_texture = load(Global.cookiedat[cookie_key]['icon'])
		var icon = Sprite2D.new()
		icon.texture = icon_texture
		icon.name = "prog_icon_" + str(n)
		icon.scale = Vector2(icon_scale, icon_scale)
		icon.z_index = 1
		var mid = deg_to_rad((start_angle + (360 * ratio)/2)-90)
		icon.position = Vector2(icon_radius, 0).rotated(mid)
		icon.rotation = mid + PI * 0.5
		center.add_child(icon)
		
		# start angle for next cookie
		start_angle += 360 * ratio
		n += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		print(get_local_mouse_position())
