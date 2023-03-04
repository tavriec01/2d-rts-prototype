extends CharacterBody2D
class_name Unit

@export var selected = false
@onready var box = get_node("Box")
@onready var anim = get_node("AnimationPlayer")
@onready var line = get_tree().get_root().get_node("World/Drawing/Line2D")
@onready var astar = get_tree().get_root().get_node("World/Astar")
@onready var worldPath = get_tree().get_root().get_node("World")
@onready var raySE = get_node("RaySE")
@onready var raySW = get_node("RaySW")
@onready var rayNE = get_node("RayNE")
@onready var rayNW = get_node("RayNW")
@onready var rayE = get_node("RayE")
@onready var rayW = get_node("RayW")

var _timer = 0

var path = PackedVector2Array()
var path_straight = PackedVector2Array()
var bypass = PackedVector2Array()
var isFollowCursor = false
var Speed = 50.0
@onready var target = position
var SpeedComputed
var targetFinal
var last_direction = Vector2(0, 1)
var norm_direction

var state
var sub_state

signal right_clicked

func _ready():
	set_state(state)
	set_selected(selected)
	add_to_group("units", true)

func set_state(s, sub=""):
	_timer = 0
	state = s
	if sub:
		if sub_state != sub:
			pass
		sub_state = sub
		

func set_selected(value):
	selected = value
	box.visible = value
	
func _input(event):
	if event.is_action_released("RightClick"):
		isFollowCursor = false
	if event.is_action_pressed("RightClick"):
		isFollowCursor = true
		
func _physics_process(delta):
	_timer += delta
	
	call(state)
	moving(delta)
	
	#if !is_nan(SpeedComputed.x) or !is_nan(SpeedComputed.y):
		#if SpeedComputed.x == 0 or SpeedComputed.y == 0:	
			#find_path()
			
func set_path(_path: PackedVector2Array):
	path = _path
	if path != bypass or path != path_straight:
		path = path.slice(1)
	for i in range(path.size()):
		var count_startX = i
		var count_currX = i
		var count_startY = i
		var count_currY = i
		#print(path)
		while count_currX < path.size()-1 and path[count_currX].x == path[count_currX+1].x:
			#print(path[count_curr])
			if path[count_currX+1] != null:
				count_currX+=1
		if count_currX != count_startX:
			if count_currX-count_startX > 2:
				for j in count_currX-count_startX-1:
					if count_startX+j < path.size()-1:
						path.remove_at(count_startX+j)
		while count_currY < path.size()-1 and path[count_currY].y == path[count_currY+1].y:
			#print(path[count_curr])
			if path[count_currY+1] != null:
				count_currY+=1
		if count_currY != count_startY:
			if count_currY-count_startY > 2:
				for j in count_currY-count_startY-1:
					if count_startY+j < path.size()-1:
						path.remove_at(count_startY+j)
		#print(path)
	
func moving(delta):
	if isFollowCursor:
		if selected:
			#bypass.clear()
			target = get_global_mouse_position()
			targetFinal = target
			#emit_signal("right_clicked", self, targetFinal)
			#path_straight.append(position)
			path_straight.remove_at(1)
			path_straight.append(targetFinal)
			set_path(path_straight)
	if !path.is_empty():
		_move_along_path(delta)
		animates_unit(velocity)
	else:
		animates_unit_idle(velocity)
	#print("s = ", SpeedComputed)
	#print("d = ", norm_direction)
	#print("v = ", velocity)
	
	search_for_obstacles()
	
func search_for_obstacles():
	#print(rayNE.is_colliding(), raySE.is_colliding())
	if rayNE.is_colliding() and get_animation_direction_8dir(velocity) == "top-left":
		bypass.clear()
		path_straight.clear()
		bypass.append(Vector2(position.x-5, position.y+1))
		if targetFinal != null:
			bypass.append(targetFinal)
		print(bypass)
		set_path(bypass)
	if rayNE.is_colliding() and get_animation_direction_8dir(velocity) == "top":
		bypass.clear()
		path_straight.clear()
		bypass.append(Vector2(position.x-15, position.y+1))
		if targetFinal != null:
			bypass.append(targetFinal)
		print(bypass)
		set_path(bypass)
	if rayNE.is_colliding() and get_animation_direction_8dir(velocity) == "left":
		bypass.clear()
		path_straight.clear()
		bypass.append(Vector2(position.x-15, position.y+1))
		if targetFinal != null:
			bypass.append(targetFinal)
		print(bypass)
		set_path(bypass)
	if rayE.is_colliding() and get_animation_direction_8dir(velocity) == "top-right":
		bypass.clear()
		path_straight.clear()
		bypass.append(Vector2(position.x-1, position.y-15))
		if targetFinal != null:
			bypass.append(targetFinal)
		print(bypass)
		set_path(bypass)
	

func _move_along_path(delta):
	var distance = Speed * delta
	#_rotate_to_path(path[0])
	for i in range(path.size()):
		var next_point = path[0]
		var dist_to_next_point = position.distance_to(next_point)
		if distance <= dist_to_next_point and distance >= 0.0:
			velocity = position.direction_to(next_point).normalized() * Speed
			move_and_slide()
			break
		distance -= dist_to_next_point
		velocity = position.direction_to(next_point).normalized() * Speed
		move_and_slide()
		path = path.slice(1)
		
func _rotate_to_path(point):
	var dir_to_point = position.direction_to(point).normalized() * Speed
	var rotation_cost = 0
	var last_dir_anim = get_animation_direction(last_direction)
	var next_dir_anim = get_animation_direction(dir_to_point)
	if last_dir_anim != next_dir_anim:
		print(last_dir_anim, "  :  ", next_dir_anim)
		if (last_dir_anim == "down" and next_dir_anim == "top"):
			print()
		if (last_dir_anim == "top" and next_dir_anim == "down"):
			print(2)
			

func get_animation_direction(direction):
	norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "top"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"
	
func get_animation_direction_8dir(direction):
	norm_direction = direction.normalized()
	if norm_direction.y >= 0.873:
		return "down"
	elif norm_direction.y >= 0.487 and norm_direction.x > -0.873 and norm_direction.x <= -0.487:
		return "down-left"
	elif norm_direction.x <= -0.873:
		return "left"
	elif norm_direction.y > -0.873 and norm_direction.x <= -0.487:
		return "top-left"
	elif norm_direction.y <= -0.873:
		return "top"
	elif norm_direction.y > -0.873 and norm_direction.x < 0.873 and norm_direction.y <= -0.487:
		return "top-right"
	elif norm_direction.x >= 0.873:
		return "right"
	elif norm_direction.y < 0.873 and norm_direction.x >= 0.487:
		return "down-right"
	return "down"
	
func animates_unit(direction):
	if direction != Vector2.ZERO:
		last_direction = direction
		var animation = get_animation_direction(last_direction) + "_walk"
		anim.play(animation)
	

func animates_unit_idle(direction):
	last_direction = direction
	var animation = get_animation_direction(last_direction) + "_idle"
	anim.play(animation)

func _on_unit_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
