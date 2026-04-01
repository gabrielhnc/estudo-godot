extends CharacterBody2D

# ================================================================
# REFERÊNCIAS DOS NÓS
# ================================================================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var state_machine: StateMachine = $StateMachine

# Referências diretas aos estados para facilitar as transições
@onready var idle_state: IdleState = $StateMachine/IdleState
@onready var walk_state: WalkState = $StateMachine/WalkState
@onready var jump_state: JumpState = $StateMachine/JumpState
@onready var fall_state: FallState = $StateMachine/FallState
@onready var duck_state: DuckState = $StateMachine/DuckState
@onready var slide_state: SlideState = $StateMachine/SlideState
@onready var dead_state: DeadState = $StateMachine/DeadState
@onready var dance_state: DanceState = $StateMachine/DanceState

# ================================================================
# DIREÇÃO
# ================================================================
var direction: float = 0.0

# ================================================================
# VELOCIDADE / ACELERAÇÃO
# ================================================================
@export var max_speed: float = 130.0
@export var acceleration: float = 1500.0
@export var deceleration: float = 1500.0

# ================================================================
# SLIDE
# ================================================================
@export var slide_deceleration: float = 200.0
@export var slide_multiplicator: float = 1.8

# ================================================================
# JUMP
# ================================================================
@export var max_jump_count: int = 2
@export var jump_velocity: float = -250.0
var jump_count: int = 0

# ================================================================
# INICIALIZAÇÃO
# ================================================================
func _ready() -> void:
	# Garante que cada instância tenha seu próprio shape (evita mutação compartilhada)
	collision_shape.shape = collision_shape.shape.duplicate()
	hitbox_collision_shape.shape = hitbox_collision_shape.shape.duplicate()

	state_machine.init(idle_state)

# ================================================================
# PROCESSO FÍSICO — gravity + move_and_slide ficam aqui
# A lógica de estado fica nos arquivos de cada estado
# ================================================================
func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * _delta
	move_and_slide()

# ================================================================
# COLISÃO COM INIMIGOS E ÁREAS LETAIS
# ================================================================
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func hit_enemy(area: Area2D) -> void:
	# Slide mata o inimigo
	if state_machine.current_state == slide_state:
		area.get_parent().take_damage()
		return

	# Quicou em cima do inimigo
	if velocity.y > 0:
		area.get_parent().take_damage()
		state_machine.transition_to(jump_state)
	else:
		if state_machine.current_state != dead_state:
			state_machine.transition_to(dead_state)

func hit_lethal_area() -> void:
	state_machine.transition_to(dead_state)

# ================================================================
# FUNÇÕES AUXILIARES — usadas pelos estados
# ================================================================

# Atualiza direção e flip do sprite
func update_direction() -> void:
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

# Movimento horizontal com aceleração/desaceleração
func move(delta: float) -> void:
	update_direction()

	if not is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

# Verifica se pode pular (double jump ou mais)
func can_jump() -> bool:
	return jump_count < max_jump_count

# Executa o pulo — chamado pelo JumpState e FallState
func do_jump() -> void:
	velocity.y = jump_velocity
	jump_count += 1
	anim.play("jump")

# Colider pequeno (agachado / slide)
func set_small_collider() -> void:
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

	hitbox_collision_shape.shape.size.y = 12
	hitbox_collision_shape.position.y = 2

# Colider original (idle / walk / ...)
func set_large_collider() -> void:
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0

	hitbox_collision_shape.shape.size.y = 16
	hitbox_collision_shape.position.y = 0

func get_slide_speed() -> float:
	return max_speed * slide_multiplicator

# ================================================================
# RELOAD DA CENA AO MORRER
# ================================================================
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
