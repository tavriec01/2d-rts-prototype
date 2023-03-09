extends StateMachine

enum Commands {
	NONE, 
	MOVE, 
	ATTACK_MOVE, 
	HOLD
}
var command = Commands.NONE

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
			parent.movement_target = event.position
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
				parent.move_to_target(delta, parent.attack_target.get_ref().position)
			else:
				set_state(states.idle)
		states.attacking:
			pass
		states.dying:
			pass

func _enter_state(new_state, old_state):
	print(new_state)
	match state:
		states.idle:
			if parent.facing_forward:
				parent.sprite.frames = parent.idle_forward_frames
			else:
				parent.sprite.frames = parent.idle_back_frames
		states.moving:
			if parent.position.x < parent.movement_target.x:
				parent.sprite.flip_h = false
			elif parent.position.x > parent.movement_target.x:
				parent.sprite.flip_h = true
			if parent.position.y < parent.movement_target.y:
				parent.sprite.frames = parent.walking_forward_frames
				parent.facing_forward = true
			elif parent.position.y > parent.movement_target.y:
				parent.sprite.frames = parent.walking_back_frames
				parent.facing_forward = false
		states.engaging:
			if parent.position.x < parent.attack_target.get_ref().position.x:
				parent.sprite.flip_h = false
			elif parent.position.x > parent.attack_target.get_ref().position.x:
				parent.sprite.flip_h = true
			if parent.position.y < parent.attack_target.get_ref().position.y:
				parent.sprite.frames = parent.walking_forward_frames
				parent.facing_forward = true
			elif parent.position.y > parent.attack_target.get_ref().position.y:
				parent.sprite.frames = parent.walking_back_frames
				parent.facing_forward = false
		states.attacking:
			if parent.facing_forward:
				parent.sprite.frames = parent.attack_forward_frames
			else:
				parent.sprite.frames = parent.attack_back_frames
		states.dying:
			if parent.facing_forward:
				parent.sprite.frames = parent.die_forward_frames
			else:
				parent.sprite.frames = parent.die_back_frames

func _exit_state(old_state, new_state):
	match old_state:
		states.attacking:
			if new_state == states.idle:
				parent.attack_target = null
		states.moving:
			if new_state != states.moving and command != Commands.ATTACK_MOVE:
				parent.movement_target = parent.positionS

func _get_transition(delta):
	match state:
		states.idle:
			if parent.closest_enemy() != null:
				parent.attack_target = parent.closest_enemy()
				set_state(states.engaging)
		states.moving:
			if parent.position.distance_to(parent.movement_target) < parent.target_max:
				parent.movement_target = parent.position
				set_state(states.idle)
		states.engaging:
			if parent.closest_enemy_within_range() != null:
				parent.attack_target = weakref(parent.closest_enemy())
				if parent.attack_target.get_ref():
					parent.attack_target.get_ref().take_damage()
				set_state(states.engaging)
		states.attacking:
			pass
		states.dying:
			pass

func died():
	set_state(states.dying)

func _on_stop_timer_timeout():
	if parent.get_slide_collision_count():
		if parent.last_distance_to_target < parent.position.distance_to(parent.movement_target) + parent.move_treshold:
			parent.movement_target = parent.position
			parent.path.remove_at(0)
			set_state("idle")


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
