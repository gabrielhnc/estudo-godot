# ================================================================
# GERENCIADOR DA FSM
# Responsável por controlar as transições entre estados
# ================================================================
class_name StateMachine
extends Node

var current_state: State

func _ready() -> void:
	# Injeta a referência do player (owner) em todos os estados filhos
	for child in get_children():
		if child is State:
			child.player = owner

# Chamado pelo player._ready() para definir o estado inicial
func init(initial_state: State) -> void:
	current_state = initial_state
	current_state.enter()

# Realiza a transição entre estados
func transition_to(new_state: State) -> void:
	if new_state == current_state:
		return
	current_state.exit()
	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
