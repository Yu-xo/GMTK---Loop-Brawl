extends Node
#Setting data for saving,loading and resetting settings to default. Stores data.

# Video Settings
var fullscreen: bool = false
var quality: String = "Best"  #Low, Medium, High, Best

# Audio Settings
var master_volume: float = 50.0
var music_volume: float = 50.0
var sfx_volume: float = 50.0
var save_path = "user://settings.cfg"

const TITLE = preload("res://Scenes/Interface/Title/Title.tscn")
const SETTINGS = preload("res://Scenes/Interface/Settings/settings.tscn")
const FLOOR_1 = preload("res://Scenes/Levels/Floor_1.tscn")

var settings
var audio_players = []

func _ready() -> void:
	load_settings()

func _process(delta: float) -> void:
	check_audio()

func set_audio(bus: int, volume: float):
	match bus:
		0:
			master_volume = volume * 100.0
		1:
			music_volume = volume * 100.0
		2:
			sfx_volume = volume * 100.0
	AudioServer.set_bus_volume_db(bus, linear_to_db(volume))
	print("Audio adjusted: ", volume)

## Saves current setting configurations to user://settings.cfg
func save_settings():
	var config = ConfigFile.new()
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "quality", quality)

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	var err := config.save(save_path)
	if err == OK:
		print("Settings saved to: ", save_path)
	else:
		print("Error, settings failed to save.")

## Loads previous setting configurations from usser://settings.cfg
func load_settings():
	var config = ConfigFile.new()
	var err := config.load(save_path)

	if err != OK:
		print("No previous save found.")
		restore_defaults()
		save_settings()
		return

	print("Previous save data found, pulling")
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
	quality = config.get_value("video", "quality", quality)

	master_volume = config.get_value("audio", "master_volume", master_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)

## Sets settings back to the defaults then saves them to file automatically
func restore_defaults():
	fullscreen = false
	quality = "Best"
	master_volume = 50.0
	music_volume = 50.0
	sfx_volume = 50.0

	#apply_new_inputmap()
	save_settings()

## Calls to save the settings on exiting the game via quit or the X
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Saving...")
		save_settings()

## Creates an audio node with a given ID and plays the given audio regardless of scene changes.
func play_audio(audio: AudioStream, id: int, bus: String): #0 Master, 1 Music, 2 SFX
	for x in audio_players.size():
		var c = audio_players[x]
		if c.get_meta("id") != 9: #Sketchy fix for now, ID 9 will always ignore this check to allow for multiples. Mainly for SFX overlap.
			if c.get_meta("id") == id:
				return
	var audio_player = AudioStreamPlayer.new()
	audio_player.set_meta("id", id)
	add_child(audio_player)
	audio_player.bus = bus
	audio_player.set_stream(audio) ; audio_player.play()
	audio_players.append(audio_player)

## Checks if audio is playing, otherwise removes it, called every frame.
func check_audio():
	for i in range(audio_players.size() -1, -1, -1):
		var a = audio_players[i]
		if !a.is_playing():
			a.queue_free()
			audio_players.remove_at(i)

## Deprecated temporarily, only works on a scene by scene basis for now.
func stop_audio(id):
	for audio in audio_players.size():
		var c = audio_players[audio]
		var meta = c.get_meta("id")
		if c.get_meta("id") == meta:
			print("This audio player exists, removing.")
			c.stop()
			c.queue_free()
			audio_players.erase(c)

## Temporarily deprecated, not recommended.
func show_settings(boolean : bool) -> void:
	match boolean:
		true:
			settings = SETTINGS.instantiate()
			add_child(settings)
		false:
			if settings:
				settings.queue_free()
			else:
				push_warning("No settings screen was found.")
				return

func load_level(path: String):
	get_tree().change_scene_to_file(path)
