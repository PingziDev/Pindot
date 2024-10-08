## 声音管理器
##
## 用于统一处理背景音乐,音效
class_name PindotSound
extends Node

# BGM 默认淡入淡出的持续时间
@export var default_fade_duration: float = 2.0

## 当前播放的背景音乐
var current_bgm: AudioStream

## 记录所有player的默认音量
var player_default_volumes: Dictionary  # {player: default_volume}

var fade_out_tween: Tween
var fade_in_tween: Tween

var curr_bgm_player: AudioStreamPlayer


## 设置当前bgm播放器
## 同时只会有激活1个bgm播放器
func set_active(bgm_player: AudioStreamPlayer, duration: float = default_fade_duration):
	# 淡出之前的播放器
	if curr_bgm_player:
		fade_out(curr_bgm_player, duration)

	# 设置新的播放器
	curr_bgm_player = bgm_player

	# 记录默认音量
	if !player_default_volumes.has(curr_bgm_player):
		player_default_volumes[curr_bgm_player] = curr_bgm_player.volume_db

	# 淡入新的播放器
	fade_in(curr_bgm_player, duration)


## 淡出声音
func fade_out(player: AudioStreamPlayer, duration: float):
	if fade_out_tween:
		fade_out_tween.kill()
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(player, "volume_db", -80, duration)
	await fade_out_tween.finished
	player.stop()


## 淡入声音
func fade_in(player: AudioStreamPlayer, duration: float):
	if fade_in_tween:
		fade_in_tween.kill()
	var final_volume = player.volume_db
	if player_default_volumes.has(player):
		final_volume = player_default_volumes[player]
	fade_in_tween = create_tween()
	fade_in_tween.tween_property(player, "volume_db", final_volume, duration).from(-80)
	player.play()
