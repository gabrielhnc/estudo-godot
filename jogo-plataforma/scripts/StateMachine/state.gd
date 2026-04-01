# ================================================================
# CLASSE BASE — TODOS OS ESTADOS HERDAM DESTA CLASSE
# Equivalente a uma classe abstrata no Java
# ================================================================
class_name State
extends Node

# Referência ao player — injetada pela StateMachine no _ready
var player: CharacterBody2D

# Chamado ao ENTRAR no estado
func enter() -> void:
	pass

# Chamado ao SAIR do estado
func exit() -> void:
	pass

# Equivalente ao _process (lógica visual, não física)
func update(_delta: float) -> void:
	pass

# Equivalente ao _physics_process (movimento, colisão)
func physics_update(_delta: float) -> void:
	pass
