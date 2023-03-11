extends StateMachine

enum Commands {
	NONE, 
	MOVE, 
	ATTACK_MOVE, 
	HOLD
}
var command : int = Commands.NONE

enum CommandMods {
	NONE,
	ATTACK_MOVE
}
var command_mod = CommandMods.NONE

func _ready():
	add_state("idle")
	add_state("moving")
	add_state("engaging")
	add_state("attacking")
	add_state("dying")
	call_deferred("set_state", states.idle)


func _input(event):
	if parent.selected and state != states.dying:
		if Input.is_action_just_pressed("AttackMove"):
			command_mod = CommandMods.ATTACK_MOVE
		if Input.is_action_just_pressed("Hold"):
			command = Commands.HOLD
			set_state(states.idle)
		if Input.is_action_just_released("RightClick"):
			set_state(states.moving)
			match command_mod:
				CommandMods.NONE:
					command = Commands.MOVE
				CommandMods.ATTACK_MOVE:
					command = Commands.ATTACK_MOVE

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.moving:
			parent.move_to_target(delta, parent.movement_target)
		states.engaging:
			if parent.attack_target.get_ref():
				parent.isEngaging = true
				parent.move_to_target(delta, parent.attack_target.get_ref().position)
			else:
				parent.isEngaging = false
				set_state(states.idle)
		states.attacking:
			pass
		states.dying:
			pass

func _enter_state(new_state, previous_state):
	match state:
		states.idle:
			pass
		states.moving:
			pass
		states.engaging:
			pass
		states.attacking:
			pass
		states.dying:
			pass

func _exit_state(previous_state, new_state):
	match previous_state:
		states.attacking:
			if new_state == states.idle:
				parent.attack_target = null
		states.moving:
			if new_state != states.moving and command != Commands.ATTACK_MOVE:
				parent.movement_target = parent.position
				parent.path.remove_at(0)

func _get_transition(delta):
	match state:
		states.idle:
			match command:
				Commands.HOLD:
					if parent.closest_enemy_within_range() != null:
						parent.attack_target = weakref(parent.closest_enemy_within_range())
						set_state(states.attacking)
				Commands.ATTACK_MOVE:
					set_state(states.moving)
				Commands.NONE:
					if parent.closest_enemy() != null:
						parent.attack_target = weakref(parent.closest_enemy())
						set_state(states.engaging)
		states.moving:
			if (command == Commands.ATTACK_MOVE):
				if parent.closest_enemy() != null:
					parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.engaging)
			if parent.position.distance_to(parent.movement_target) < parent.target_max:
				parent.movement_target = parent.position
				parent.path.remove_at(0)
				set_state(states.idle)
				command = Commands.NONE
		states.engaging:
			if parent.closest_enemy_within_range() != null:
				parent.attack_target = weakref(parent.closest_enemy())
				set_state(states.attacking)
		states.attacking:
			if !parent.attack_target.get_ref():
				set_state(states.idle)
				parent.attack_target = null
		states.dying:
			pass

func died():
	set_state(states.dying)

func _on_stop_timer_timeout():
	if parent.get_slide_collision_count():
		if parent.last_distance_to_target < parent.position.distance_to(parent.movement_target) + parent.move_treshold:
			parent.movement_target = parent.position
			parent.path.remove_at(0)
			set_state(states.idle)


func _on_animation_player_animation_finished(anim_name):
	match state:
		states.attacking:
			if parent.attack_target.get_ref():
				if parent.attack_target.get_ref().take_damage(parent.damage_amount):
					if parent.closest_enemy_within_range():
						pass
					else:
						set_state(states.engaging)
				else:
					set_state(states.idle)
			else:
				set_state(states.idle)
		states.dying:
			parent.queue_free()
