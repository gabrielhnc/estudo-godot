# ================================================================
# FALL STATE
# ================================================================
class_name FallState
extends State

func enter() -> void:
	player.anim.play("fall")

func physics_update(delta: float) -> void:
	player.move(delta)

	if Input.is_action_just_pressed("dance"):
		player.state_machine.transition_to(player.dance_state)
		return

	# Double jump durante a queda
	if Input.is_action_just_pressed("jump") and player.can_jump():
		player.do_jump()
		player.state_machine.transition_to(player.jump_state)
		return

	# Pousou no chão
	if player.is_on_floor():
		player.jump_count = 0

		if is_zero_approx(player.velocity.x):
			player.state_machine.transition_to(player.idle_state)
		else:
			player.state_machine.transition_to(player.walk_state)
		return
