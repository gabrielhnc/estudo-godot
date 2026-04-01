# ================================================================
# JUMP STATE
# ================================================================
class_name JumpState
extends State

func enter() -> void:
	player.do_jump()

func physics_update(delta: float) -> void:
	player.move(delta)

	if Input.is_action_just_pressed("dance"):
		player.state_machine.transition_to(player.dance_state)
		return

	# Double jump — chama do_jump direto sem transition_to (já está no jump_state)
	if Input.is_action_just_pressed("jump") and player.can_jump():
		player.do_jump()
		return

	# Começou a cair
	if player.velocity.y > 0:
		player.state_machine.transition_to(player.fall_state)
		return
