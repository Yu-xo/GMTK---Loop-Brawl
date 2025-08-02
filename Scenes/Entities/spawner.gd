extends Node2D

@onready var enemy_scene = preload("res://Scenes/Enemies/mobs/enemy.tscn")
@onready var elite_enemy_scene = preload("res://Scenes/Enemies/Elites/elite_red.tscn")
#@onready var boss_enemy_scene = preload("res://Scenes/Enemies/mobs/boss_enemy.tscn")

@export var spawn_points: Array[Marker2D]

var floor_level := Global.Floor_number
var can_spawn := false

func _on_timer_timeout() -> void:
	can_spawn = true
	if can_spawn:
		_spawn_wave_for_floor(floor_level)
		can_spawn = false

func _spawn_wave_for_floor(floor: int) -> void:
	if spawn_points.is_empty():
		print("No spawn points assigned.")
		return

	var regular_count := 0
	var elite_count := 0
	var spawn_boss := false

	match floor:
		1:
			regular_count = 7
		2:
			regular_count = 10
		3:
			regular_count = 12
			elite_count = 1
		4:
			regular_count = 10
			elite_count = 1
		5:
			elite_count = 2
			spawn_boss = true

	# Spawn regular enemies
	for i in range(regular_count):
		_spawn_enemy(enemy_scene)

	# Spawn elite enemies
	for i in range(elite_count):
		_spawn_enemy(elite_enemy_scene)

	# Spawn boss
'	if spawn_boss:
		_spawn_enemy(boss_enemy_scene)
'
func _spawn_enemy(scene: PackedScene) -> void:
	var spawn_point = spawn_points.pick_random()
	var enemy = scene.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)

	# Optional: scale stats
	if enemy.has_method("scale_difficulty"):
		enemy.scale_difficulty(floor_level)
