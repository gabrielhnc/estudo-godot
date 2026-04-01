# ================================================================
# WALK STATE
# ================================================================
class_name WalkState
extends State

func enter() -> void:
	player.anim.play("walk")

func physics_update(delta: float) -> void:
	player.move(delta)

	if Input.is_action_just_pressed("dance"):
		player.state_machine.transition_to(player.dance_state)
		return

	if Input.is_action_just_pressed("jump") and player.can_jump():
		player.state_machine.transition_to(player.jump_state)
		return

	if Input.is_action_just_pressed("slide"):
		player.state_machine.transition_to(player.slide_state)
		return

	# Saiu do chão sem pular (caiu de uma plataforma)
	if not player.is_on_floor():
		player.jump_count += 1
		player.state_machine.transition_to(player.fall_state)
		return

	if is_zero_approx(player.velocity.x):
		player.state_machine.transition_to(player.idle_state)
		return
