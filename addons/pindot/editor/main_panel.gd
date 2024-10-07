@tool
@icon("res://icon.svg")
extends Control


func _on_button_pressed() -> void:
	print("Hello world!")
	var config_file = ProjectSettings.get_setting("Pindot/config_file")
	print("a = %s" % config_file)

	var config: PindotConfig = load(config_file)
	print("b = %s" % config.log_level)
