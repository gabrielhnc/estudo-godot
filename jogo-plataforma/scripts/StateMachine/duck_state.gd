# ================================================================
# DUCK STATE
# ================================================================
class_name DuckState
extends State

func enter() -> void:
	player.anim.play("duck")
	player.set_small_collider()

func exit() -> void:
	player.set_large_collider()

func physics_update(_delta: float) -> void:
	player.update_direction()

	if Input.is_action_just_released("duck"):
		player.state_machine.transition_to(player.idle_state)
		return
