extends StaticBody2D

@onready var timer = $Timer
var totalTime = 0.1
var currTime
var mouseEntered = false
var isSelected = false
@onready var select = get_node("Selected")

# Called when the node enters the scene tree for the first time.
func _ready():
	currTime = totalTime
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	select.visible = isSelected
	if currTime <= 0:
		goldCollected()

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == true:
			isSelected = true
			if isSelected == true:
				Game.minePanelCall()

func _on_timer_timeout():
	currTime -= 1
	#var tween = get_tree().create_tween()
	#tween.tween_property(bar, "value", currTime, 0.1).set_trans(Tween.TRANS_LINEAR)
	
func goldCollected():
	Game.Gold += 5
	_ready()

func _on_mine_mouse_entered():
	mouseEntered = true


func _on_mine_mouse_exited():
	mouseEntered = false
