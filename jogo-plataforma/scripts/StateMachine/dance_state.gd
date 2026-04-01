# ================================================================
# DANCE STATE
# ================================================================
class_name DanceState
extends State

func enter() -> void:
	player.anim.play("dance")
	# Conecta o sinal animation_finished para detectar quando a dança acabou
	# CONNECT_ONE_SHOT desconecta automaticamente após a primeira chamada
	player.anim.animation_finished.connect(_on_dance_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	# Garante que o sinal seja desconectado se sairmos antes da animação terminar
	if player.anim.animation_finished.is_connected(_on_dance_finished):
		player.anim.animation_finished.disconnect(_on_dance_finished)

func physics_update(delta: float) -> void:
	player.move(delta)

	if Input.is_action_just_pressed("jump") and player.can_jump():
		player.state_machine.transition_to(player.jump_state)
		return

func _on_dance_finished() -> void:
	player.state_machine.transition_to(player.idle_state)
