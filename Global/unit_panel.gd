extends Node2D

@onready var unit = preload("res://unit/Unit.tscn")
@onready var worldPath = get_tree().get_root().get_node("World")
@onready var unitCounter = $UnitCounterLabel
var screenSize = Vector2()
var mouseEntered = false
var mousePos = Vector2()
var currUnit
var unitPath

func _ready():
	screenSize = get_viewport_rect().size
	unitPath = get_tree().get_root().get_node("World/Units")
	screenSize = get_viewport_rect().size
	position.x = 50
	position.y = screenSize.y - 150
	mousePos = get_global_mouse_position()
	unitCounter.text = str(worldPath.unitCounterToTransfer)

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
			queue_free()
			
	
func _on_building_button_pressed():
	unitPath = get_tree().get_root().get_node("World/Units")
	var worldPath = get_tree().get_root().get_node("World")
	



