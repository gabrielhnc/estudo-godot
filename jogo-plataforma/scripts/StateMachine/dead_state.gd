# ================================================================
# DEAD STATE
# ================================================================
class_name DeadState
extends State

func enter() -> void:
	player.anim.play("dead")
	player.velocity.x = 0
	player.reload_timer.start()

# Sem lógica de update — o ReloadTimer cuida do reload da cena
