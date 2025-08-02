extends Node

# --- Player Stats ---
var max_health: int = 10
var base_attack: int = 1
var current_run_attack: int = base_attack
var current_run_health: int = max_health

# --- Stage Stats ---
var Floor_number : int = 1

# --- Enemy Stats ---
var ene_health :int=1
var ene_attack : int=1

# --- Death Tracking ---
var death_count: int = 0

# --- Echo System ---
var last_echo_data: Array = []
var has_echo: bool = false

# --- Run Info ---
var run_timer: float = 0.0

func Floor_leveling_system():
	for i in range(Floor_number):
		ene_attack +=1
		ene_health +=1
		print(Floor_number)
# Call this on each new run
func reset_for_new_run():
	current_run_attack = base_attack
	current_run_health = max_health
	run_timer = 0.0
	current_run_health = max_health
# Call this on death
func apply_death_penalties():
	death_count += 1
	max_health = max(1, max_health - 1)
	base_attack += 1
	has_echo = true
