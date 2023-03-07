extends StateMachine

func _ready():
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	call_deferred("set_state", states.idle)


func _input(event):
	if parent.selected and state != states.dying:
		if Input.is_action_just_released("RightClick"):
			parent.movement_target = event.position
			set_state("moving")

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.moving:
			parent.move_to_target(delta, parent.movement_target)
		states.engaging:
			pass
		states.attacking:
			pass
		states.dying:
			pass
