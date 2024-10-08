@icon("res://addons/pindot/icon.svg")
extends Node

## 声音管理器
var sound: PindotSound


func _ready() -> void:
	sound = PindotSound.new()
	add_child(sound)
