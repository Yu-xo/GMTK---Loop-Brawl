extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEATH
}

@onready var player: Sprite2D = $player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $UI/Health/health_bar
@onready var timer_label: Label = $UI/Text_labels/Timer
@onready var death_label: Label = $"UI/Text_labels/Number of deaths"
@onready var attack_power_label: Label = $"UI/Text_labels/Attak Power"
@onready var punch: Area2D = $punch
@onready var slash: Sprite2D = $Slash

@export var speed := 100

var attack = Global.base_attack
var health: int = 10
var dir := Vector2.ZERO
var time_elapsed := 0.0
var GameState = Global

var current_state: State = State.IDLE
var attack_timer := 0.0
const ATTACK_DURATION := 0.4
var attack_index := 0  # 0 for attack_1, 1 for attack_2

func _ready():
	slash.visible =false
	health = GameState.current_run_health
	GameState.reset_for_new_run()

	health_bar.max_value = GameState.current_run_health
	health_bar.value = GameState.current_run_health
	timer_label.text = "Time: 0"
	death_label.text = "Deaths: %d" % GameState.death_count
	attack_power_label.text = "ATK: %d" % GameState.current_run_attack

func _physics_process(delta: float) -> void:
	update_timer(delta)
	match current_state:
		State.IDLE, State.RUN:
			movement()
			update_animation()
		State.ATTACK:
			attack_timer -= delta
			if attack_timer <= 0:
				current_state = State.IDLE
		State.DEATH:
			velocity = Vector2.ZERO

	move_and_slide()
	update_health_ui()
	check_player_death()

func _unhandled_input(event: InputEvent) -> void:
	if current_state in [State.IDLE, State.RUN]:
		if Input.is_action_just_pressed("punch"):
			_attack()

func _attack() -> void:
	current_state = State.ATTACK
	attack_timer = ATTACK_DURATION

	if attack_index == 0:
		animation_player.play("attack_1")
	else:
		animation_player.play("attack_2")

	attack_index = 1 - attack_index  # toggle between 0 and 1

func movement():
	dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed

	if dir.x > 0:
		player.flip_h = false
		punch.position = Vector2(abs(punch.position.x), punch.position.y)
	elif dir.x < 0:
		player.flip_h = true
		punch.position = Vector2(-abs(punch.position.x), punch.position.y)

	current_state = State.RUN if dir != Vector2.ZERO else State.IDLE

func update_animation():
	match current_state:
		State.RUN:
			animation_player.play("run")
		State.IDLE:
			animation_player.play("idle")

func take_damage(amount: int) -> void:
	health -= amount
	GameState.current_run_health = health
	if health <= 0:
		die()

func die() -> void:
	current_state = State.DEATH
	animation_player.play("death")
	animation_player.stop()
	GameState.apply_death_penalties()
	GameState.max_health = max(GameState.max_health - 1, 1)
	GameState.current_run_attack += 1
	GameState.death_count += 1
	await get_tree().create_timer(1.0).timeout
	_restart_loop()

func _restart_loop():
	GameState.reset_for_new_run()
	health = GameState.current_run_health
	health_bar.max_value = GameState.max_health
	health_bar.value = health
	attack_power_label.text = "ATK: %d" % GameState.current_run_attack
	death_label.text = "Deaths: %d" % GameState.death_count

	time_elapsed = 0.0
	global_position = Vector2.ZERO
	current_state = State.IDLE

func update_health_ui():
	health_bar.value = GameState.current_run_health

func update_timer(delta):
	time_elapsed += delta
	timer_label.text = "Time: %.1f" % time_elapsed
	GameState.run_timer = time_elapsed

func check_player_death():
	if health <= 0 and current_state != State.DEATH:
		die()

func _on_punch_body_entered(body: Node2D) -> void:
	if body != self and current_state == State.ATTACK:
			body.health -= attack
