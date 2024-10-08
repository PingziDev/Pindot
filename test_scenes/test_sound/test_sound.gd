extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2


func _ready() -> void:
	_on_bgm_1_pressed()


func _on_bgm_1_pressed():
	Pindot.sound.set_active(audio_stream_player)


func _on_bgm_2_pressed():
	Pindot.sound.set_active(audio_stream_player_2)
