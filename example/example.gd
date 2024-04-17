extends Control

@onready var audio_stream_player: AudioStreamDirectoryPlayer = $AudioStreamDirectoryPlayer

func _ready():
	audio_stream_player.play()

func _on_button_pressed():
	audio_stream_player.play_next()
