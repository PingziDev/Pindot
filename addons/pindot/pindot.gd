@icon("res://addons/pindot/icon.svg")
extends Node

## 框架配置
var config: PindotConfig

## 声音管理器
var sound: PindotSound

## 日志输出
var log: PindotLog


func _enter_tree() -> void:
	# 始终在process中运行
	process_mode = PROCESS_MODE_ALWAYS


func _ready() -> void:
	if !ProjectSettings.has_setting("pindot/config_file"):
		printerr("Pindot 未正确加载,尝试重新启动项目和插件")

	config = load(ProjectSettings.get_setting("pindot/config_file"))

	sound = PindotSound.new()
	add_child(sound)

	log = PindotLog.new()
	add_child(log)
