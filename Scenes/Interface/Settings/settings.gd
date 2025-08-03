extends Node2D

#Directly interacts with settings storage class

const MENU_SONG_V_02 = preload("res://audio/music/MenuSong_V02.wav")
const ON_BUTTON_ENTER_V_00 = preload("res://audio/ui/OnButtonEnter_V00.wav")
const ON_CLICK_V_01_2 = preload("res://audio/ui/OnClick_V01 2.wav")
const ON_CLICK_V_01 = preload("res://audio/ui/OnClick_V01.wav")

@onready var setting_sliders ={
	$CanvasLayer/Control/Panel/VBoxContainer/Master/MasterSlider : "Master",
	$CanvasLayer/Control/Panel/VBoxContainer/Music/MusicSlider : "Music",
	$CanvasLayer/Control/Panel/VBoxContainer/SFX/SFXSlider : "SFX",
}

@onready var setting_buttons ={
	$CanvasLayer/Control/Panel/VBoxContainer/Apply : "Apply",
	$CanvasLayer/Control/Panel/VBoxContainer/Restore : "Restore",
	$CanvasLayer/Control/Panel/VBoxContainer/Back : "Back"
}

func _ready() -> void:
	setup()

func setup():
	connect_signals()
	update_ui()

func connect_signals():
	for slider in setting_sliders.keys():
		slider.value_changed.connect(_on_volume_changed.bind(setting_sliders[slider]))
	for button in setting_buttons.keys():
		button.pressed.connect(_on_button_pressed.bind(setting_buttons[button]))
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button.name))

func _on_button_mouse_entered(button: String) -> void:
	GameSettings.play_audio(ON_BUTTON_ENTER_V_00, 9, "SFX")

func _on_button_pressed(action: String) -> void:
	GameSettings.play_audio(ON_CLICK_V_01_2, 9, "SFX")
	match action:
		"Apply":
			GameSettings.save_settings()
		"Restore":
			GameSettings.restore_defaults()
			update_ui()
		"Back":
			GameSettings.load_level("res://Scenes/Interface/Title/Title.tscn")

func _on_volume_changed(value: float, type: String) -> void:
	var balanced = clamp(value / 100.0, 0.001, 1.0)
	match type:
		"Master":
			GameSettings.set_audio(0, balanced)
		"Music":
			GameSettings.set_audio(1, balanced)
			print("Music changed")
		"SFX":
			GameSettings.set_audio(2, balanced)
	update_ui()

func update_ui():
	$CanvasLayer/Control/Panel/VBoxContainer/Master/MasterSlider.value = GameSettings.master_volume
	$CanvasLayer/Control/Panel/VBoxContainer/Master.text = "Master Volume: " + str(roundi(GameSettings.master_volume))
	$CanvasLayer/Control/Panel/VBoxContainer/Music/MusicSlider.value = GameSettings.music_volume
	$CanvasLayer/Control/Panel/VBoxContainer/Music.text = "Music Volume: " + str(roundi(GameSettings.music_volume))
	$CanvasLayer/Control/Panel/VBoxContainer/SFX/SFXSlider.value = GameSettings.sfx_volume
	$CanvasLayer/Control/Panel/VBoxContainer/SFX.text = "SFX Volume: " + str(roundi(GameSettings.sfx_volume))
