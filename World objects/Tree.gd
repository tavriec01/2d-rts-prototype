extends StaticBody2D

var totalTime = 5.0
var currTime
var unitsInArea = 0
@onready var bar = $ProgressBar
@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2d
@onready var shape = collisionShape.get_shape()
@onready var astar = get_tree().get_root().get_node("World/Astar")

func _ready():
	currTime = totalTime
	bar.max_value = totalTime
	#print(shape.get_rect())
	#print(position)


func _process(delta):
	bar.value = currTime
	if currTime <= 0:
		treeChopped()


func _on_chop_area_body_entered(body):
	if "Unit" in body.name:
		unitsInArea += 1
		startChopping()


func _on_chop_area_body_exited(body):
	if "Unit" in body.name:
		unitsInArea -= 1
		if unitsInArea <=0:
			timer.stop()


func _on_timer_timeout():
	currTime -= 1*unitsInArea

func startChopping():
	timer.start()

func treeChopped():
	Game.Wood += 1
	queue_free()
