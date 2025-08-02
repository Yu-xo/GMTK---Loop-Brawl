extends CharacterBody2D

var actions := []
var current_index := 0
var playback_timer := 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _ready():
	set_physics_process(false)
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timeout)

func start_replay(recorded_actions: Array):
	actions = recorded_actions.duplicate()
	playback_timer = 0
	current_index = 0
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if current_index >= actions.size():
		return

	playback_timer += delta

	while current_index < actions.size() and actions[current_index]["time"] <= playback_timer:
		var action = actions[current_index]
		global_position = action["position"]
		animated_sprite_2d.flip_h = action["flip"]
		animated_sprite_2d.play(action["animation"])
		current_index += 1

func _on_timeout():
	queue_free()
