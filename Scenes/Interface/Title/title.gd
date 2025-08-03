extends Node2D

const MENU_SONG_V_02 = preload("res://audio/music/MenuSong_V02.wav")
const ON_BUTTON_ENTER_V_00 = preload("res://audio/ui/OnButtonEnter_V00.wav")
const ON_CLICK_V_01_2 = preload("res://audio/ui/OnClick_V01 2.wav")
const ON_CLICK_V_01 = preload("res://audio/ui/OnClick_V01.wav")
const CREDITS = preload("res://Scenes/Interface/Credits/credits.tscn")

@onready var button_container = $CanvasLayer/Control/Panel/VBoxContainer
var window_created

var sounds = []

func _ready() -> void:
	GameSettings.play_audio(MENU_SONG_V_02, 1, "Music")
	for button in button_container.get_children():
		if button is TextureButton:
			button.pressed.connect(_on_button_pressed.bind(button.name))
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button.name, button))

func _on_button_mouse_entered(name: String, node: TextureButton) -> void:
	if !node.disabled:
		GameSettings.play_audio(ON_BUTTON_ENTER_V_00, 9, "SFX")

func _on_button_pressed(action: String) -> void:
	GameSettings.play_audio(ON_CLICK_V_01, 9, "SFX")
	match action:
		"Play":
			GameSettings.load_level("res://Scenes/Levels/Floor_1.tscn")
		"Settings":
			GameSettings.load_level("res://Scenes/Interface/Settings/settings.tscn")
		"Credits":
			print("Load credits")
			window_created = CREDITS.instantiate()
			add_child(window_created)
		"Quit":
			GameSettings.save_settings()
			await get_tree().process_frame
			get_tree().quit()
