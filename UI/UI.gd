extends CanvasLayer

@onready var label = $Label
@onready var label2 = $Label2
@onready var fps_counter = $FPS_COUNTER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = "WOOD: " + str(Game.Wood)
	label2.text = "GOLD: " + str(Game.Gold)
	fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
