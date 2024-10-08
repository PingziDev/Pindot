## 播放器
##
## 记录唯一id,方便Pindot.sound统一管理
## TIP:如果背景音乐需要在游戏暂停时仍然播放,需要设置 process_mode = PROCESS_MODE_ALWAYS
@icon("res://addons/pindot/sound/sound.svg")
class_name PindotSoundPlayer
extends AudioStreamPlayer

## 唯一id
@export var id: String

## 记录默认数据
var default_volumn: float


func _ready() -> void:
	default_volumn = volume_db

	if Pindot.sound:
		autoplay = false
		stop()

		# 交由管理器统一管理
		Pindot.sound.register_player(self)


func _exit_tree() -> void:
	if Pindot.sound:
		Pindot.sound.unregister_player(self)
