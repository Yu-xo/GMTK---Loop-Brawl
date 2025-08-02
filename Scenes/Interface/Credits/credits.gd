extends Node2D

@onready var back = $CanvasLayer/Control/Panel/Back

func _ready() -> void:
	back.pressed.connect(exit_credits)

func exit_credits():
	queue_free()
