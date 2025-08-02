extends CharacterBody2D
class_name EnemyManager

# === CONFIG ===
@export var speed: float = 80
@export var health = Global.ene_health
@export var dmg = Global.ene_attack

@export var dash_distance: float = 150.0
@export var dash_duration: float = 0.3

var player_detected := false

# === TYPE SELECTION ===
enum EnemyType { MOB, ELITE_RED }
@export_enum("mob", "elite_red") var enemy_type: String = "mob"

# === NODES ===
@export var navigation: NavigationAgent2D
@export var timer_node: Timer
@export var anima: AnimationPlayer
@export var look: RayCast2D
@export var attack_area: Area2D
@onready var player = get_tree().get_first_node_in_group("player")

# === STATE ===
enum State { IDLE, CHASING, ATTACKING, SPECIAL }
var current_state: State = State.IDLE
var direction: Vector2 = Vector2.ZERO

# === READY ===
func _ready() -> void:
	add_to_group("enemies")

	if timer_node:
		timer_node.timeout.connect(_on_navigation_timer)
		timer_node.start()

	if attack_area and not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)

	change_state(State.CHASING)

# === MAIN LOOP ===
func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
		return

	match current_state:
		State.CHASING:
			_process_chasing()
			_play_animation("run")
		State.IDLE:
			velocity = Vector2.ZERO
			_play_animation("idle")
		State.ATTACKING, State.SPECIAL:
			velocity = Vector2.ZERO

	move_and_slide()
	_update_directional_facing()
	_check_player_detected()

# === BEHAVIOR ===
func _process_chasing() -> void:
	if player and navigation:
		navigation.target_position = player.global_position

	if not navigation.is_navigation_finished():
		direction = global_position.direction_to(navigation.get_next_path_position())
		velocity = velocity.lerp(direction * speed, 0.2)
	else:
		velocity = Vector2.ZERO

func _update_directional_facing() -> void:
	if not player:
		return

	var to_player = player.global_position.x - global_position.x

	if to_player > 0:
		$Sprite2D.scale.x = -1
		look.target_position = Vector2(30, 0)
		attack_area.position = Vector2(60, 0)
	else:
		$Sprite2D.scale.x = 1
		look.target_position = Vector2(-30, 0)
		attack_area.position = Vector2(-8, 0)

func _check_player_detected() -> void:
	if look.is_colliding():
		var target = look.get_collider()
		if target and target.is_in_group("player"):
			if not player_detected:
				player_detected = true
				if enemy_type == "elite_red":
					start_special_attack()
				else:
					start_attack()
	else:
		player_detected = false

# === COMBAT ===
func start_attack() -> void:
	if current_state in [State.ATTACKING, State.SPECIAL]:
		return

	change_state(State.ATTACKING)
	velocity = Vector2.ZERO
	
	anima.play("normal_attack", true)
	await anima.animation_finished
	_resume_chase_or_idle()
	
func start_special_attack() -> void:
	if current_state in [State.SPECIAL, State.ATTACKING]:
		return

	change_state(State.SPECIAL)
	velocity = Vector2.ZERO

	if enemy_type == "elite_red":
		anima.play("big_punch", true)

		await anima.animation_finished

	_resume_chase_or_idle()

func _resume_chase_or_idle() -> void:
	if player and navigation:
		navigation.target_position = player.global_position

	if player_detected:
		change_state(State.CHASING)
	else:
		change_state(State.IDLE)
	
func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and current_state in [State.ATTACKING, State.SPECIAL]:
		if body.has_method("take_damage"):
			body.take_damage(dmg)

# === UTIL ===
func _on_navigation_timer() -> void:
	if player and navigation:
		navigation.target_position = player.global_position

func change_state(new_state: State) -> void:
	current_state = new_state

func _play_animation(anim_name: String) -> void:
	if anima.current_animation != anim_name:
		anima.play(anim_name)
