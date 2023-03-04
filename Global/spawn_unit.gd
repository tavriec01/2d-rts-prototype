extends Node2D
@onready var unit = preload("res://unit/Unit.tscn")
var screenSize = Vector2()
var mouseEntered = false
var mousePos = Vector2()
var currBuilding
var buildingPath 

func _ready():
	buildingPath = get_tree().get_root().get_node("World/Buildings")
	screenSize = get_viewport_rect().size
	position.x = 50
	position.y = screenSize.y - 150

func _process(delta):
	screenSize = get_viewport_rect().size
	position.y = screenSize.y - 150
	mousePos = get_global_mouse_position()
	if mousePos.x > position.x and mousePos.x < position.x + 318:
		if mousePos.y > position.y and mousePos.y < position.y + 100:
			mouseEntered = true
		else:
			mouseEntered = false
	else:
		mouseEntered = false

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == false:
			for i in buildingPath.get_child_count():
				currBuilding = buildingPath.get_child(i)
				if currBuilding.isSelected == true:
					currBuilding.isSelected = false
				if currBuilding.mouseEntered == true and currBuilding.isSelected == false:
					currBuilding.isSelected = true
			queue_free()
			
	
func _on_worker_button_pressed():
	var unitPath = get_tree().get_root().get_node("World/Units")
	var worldPath = get_tree().get_root().get_node("World")
	
	var spawnedUnit1 = unit.instantiate()
	var spawnedUnit1Arr = [spawnedUnit1]
	for i in buildingPath.get_child_count():
		if buildingPath.get_child(i).isSelected == true:
			currBuilding = buildingPath.get_child(i)
	
	spawnedUnit1.position = currBuilding.position - Vector2(0, 25)
	print(spawnedUnit1.target)
	unitPath.add_child(spawnedUnit1)
	worldPath.get_units()
	worldPath.subscribe_to_units_signals(spawnedUnit1Arr)
	

