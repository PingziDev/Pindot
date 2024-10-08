extends Node2D

@onready var audio_stream_player: PindotSoundPlayer = $AudioStreamPlayer
@onready var audio_stream_player_2: PindotSoundPlayer = $AudioStreamPlayer2


func _ready() -> void:
	_on_bgm_1_pressed()


func _on_bgm_1_pressed():
	Pindot.sound.set_active(audio_stream_player.id)


func _on_bgm_2_pressed():
	Pindot.sound.set_active(audio_stream_player_2.id)
