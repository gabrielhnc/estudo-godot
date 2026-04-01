# ================================================================
# IDLE STATE
# ================================================================
class_name IdleState
extends State

func enter() -> void:
	player.anim.play("idle")

func physics_update(delta: float) -> void:
	player.move(delta)

	if Input.is_action_just_pressed("dance"):
		player.state_machine.transition_to(player.dance_state)
		return

	if Input.is_action_just_pressed("jump") and player.can_jump():
		player.state_machine.transition_to(player.jump_state)
		return

	if Input.is_action_just_pressed("duck"):
		player.state_machine.transition_to(player.duck_state)
		return

	if not is_zero_approx(player.velocity.x):
		player.state_machine.transition_to(player.walk_state)
		return
