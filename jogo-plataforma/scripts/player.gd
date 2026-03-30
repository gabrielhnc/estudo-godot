extends CharacterBody2D

# REFERENCIAS DOS NÓS
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer

# DIREÇÃO INICIAL
var direction = 0

# VELOCIDADE / ACELERAÇÃO
@export var max_speed = 130
@export var acceleration = 1500
@export var deceleration = 1500

# SLIDE
@export var slide_deceleration = 200
@export var slide_multiplicator = 1.8

# JUMP
@export var max_jump_count = 2
var jump_count = 0
const JUMP_VELOCITY = -250

# POSSIVEIS ESTADOS DO PLAYER (FSM -> FINITE STATE MACHINE)
enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	dead
}

var status: PlayerState

# DEFINIÇÃO DO STATUS INICIAL AO INICIAR O JOGO
func _ready() -> void:
	go_to_idle_state()

# PROCESSO CONTÍNUO DO JOGO
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)
			
	move_and_slide()

# ================================================================
# TROCA DE COMPORTAMENTOS -> STATUS (go_to)

# GO_TO IDLE STATE
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")
	
# GO_TO WALK STATE
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")
	
# GO_TO JUMP STATE
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	
# GO_TO FALL STATE
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	
# GO_TO e EXIT FROM -> DUCK STATE
func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	set_small_collider()

func exit_from_duck_state():
	set_large_collider()

# GO_TO e EXIT FROM -> SLIDE STATE
func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	set_small_collider()
	velocity.x = direction * get_slide_speed()
	
func exit_from_slide_state():
	set_large_collider()
	
# GO_TO DEAD STATE
func go_to_dead_state():
	status = PlayerState.dead
	anim.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

# ================================================================
# ESTADOS DO PLAYER (MODIFICAÇÃO CONFORME AS AÇÕES NO JOGO)

# IDLE STATE
func idle_state(delta):
	move(delta)
	
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

# WALK STATE
func walk_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if not is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
	
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("slide"):
		go_to_slide_state()
		return
	
# JUMP STATE
func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

# FALL STATE
func fall_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

# DUCK STATE
func duck_state(_delta):
	update_direction()
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("slide") or velocity.x == 0:
		exit_from_slide_state()
		go_to_walk_state()
		return
		
func dead_state(_delta):
	pass

# ================================================================
# FUNÇÕES AUXILIARES

# PRIMEIRO ATUALIZA A DIREAÇÃO E EM SEGUIDA REALIZA O MOVIMENTO
func move(delta):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
# ATUALIZAR DIREÇÃO (DIREITA / ESQUERDA)
func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

# RETORNA SE É POSSIVEL PULAR (DOUBLE JUMP OU MAIS)
func can_jump() -> bool:
	return jump_count < max_jump_count

# COLISOR PEQUENO (AGACHADO / SLIDE)
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
# COLISOR ORIGINAL (IDLE / WALK / ...)
func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func hit_enemy(area: Area2D):
	if status == PlayerState.slide:
		area.get_parent().take_damage()
		return	

	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		if status != PlayerState.dead:
			go_to_dead_state()
	
func hit_lethal_area():
	go_to_dead_state()

func get_slide_speed():
	return max_speed * slide_multiplicator

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
