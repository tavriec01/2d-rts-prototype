extends StaticBody2D

var mouseEntered = false
var isSelected = false
@onready var select = get_node("Selected")

func _ready():
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	select.visible = isSelected
	
func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == true:
			isSelected = true
			if isSelected == true:
				Game.spawnUnit()


func _on_building_mouse_entered():
	mouseEntered = true


func _on_building_mouse_exited():
	mouseEntered = false
