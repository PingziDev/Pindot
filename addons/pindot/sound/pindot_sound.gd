## 声音管理器
##
## 用于统一处理背景音乐,音效
@icon("res://addons/pindot/sound/sound.svg")
class_name PindotSound
extends Node

@export var show_debug_info: bool = false

# BGM 默认淡入淡出的持续时间
@export var default_fade_duration: float = 0.5

var fade_out_tween: Tween
var fade_in_tween: Tween

var curr_player: PindotSoundPlayer

## 记录所有播放器
var players_dict: Dictionary  # {id: PindotSoundPlayer}


func _ready() -> void:
	# 读取配置数据
	show_debug_info = Pindot.config.sound_debug


## 注册播放器
func register_player(player: PindotSoundPlayer) -> void:
	players_dict[player.id] = player
	# 将player移动到管理器下统一处理 TODO
	# player.reparent.call_deferred(self)


## 取消注册
func unregister_player(player: PindotSoundPlayer) -> void:
	players_dict.erase(player.id)


## 获取播放器
func get_player(id: String) -> PindotSoundPlayer:
	if !players_dict.has(id):
		Pindot.log.error("player %s not found" % id)
		return null
	return players_dict[id]


## 设置当前bgm播放器
## 同时只会有激活1个bgm播放器
func set_active(player_id: String, duration: float = default_fade_duration):
	if show_debug_info:
		Pindot.log.debug(
			"sound changed ===",
			(
				"old:"
				+ (curr_player.id if is_instance_valid(curr_player) else "null")
				+ "	new:"
				+ player_id
			)
		)

	if is_instance_valid(curr_player):
		if curr_player.id == player_id:
			return

		# 淡出之前的播放器
		fade_out(curr_player, duration)

	# 设置新的播放器
	curr_player = get_player(player_id)

	if curr_player:
		# 淡入新的播放器
		fade_in(curr_player, duration)


## 淡出声音
func fade_out(player: PindotSoundPlayer, duration: float):
	if fade_out_tween:
		fade_out_tween.kill()
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(player, "volume_db", -80, duration)
	await fade_out_tween.finished
	player.stop()


## 淡入声音
func fade_in(player: PindotSoundPlayer, duration: float):
	if fade_in_tween:
		fade_in_tween.kill()
	fade_in_tween = create_tween()
	fade_in_tween.tween_property(player, "volume_db", player.default_volumn, duration).from(-80)
	player.play()
