# ================================================================
# SLIDE STATE
# ================================================================
class_name SlideState
extends State

func enter() -> void:
	player.anim.play("slide")
	player.set_small_collider()
	player.velocity.x = player.direction * player.get_slide_speed()

func exit() -> void:
	player.set_large_collider()

func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.slide_deceleration * delta)

	if Input.is_action_just_released("slide") or is_zero_approx(player.velocity.x):
		# Verifica se está no chão antes de decidir o próximo estado
		if player.is_on_floor():
			player.state_machine.transition_to(player.walk_state)
		else:
			player.state_machine.transition_to(player.fall_state)
		return
