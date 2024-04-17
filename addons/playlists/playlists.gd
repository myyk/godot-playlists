@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("AudioStreamDirectoryPlayer", "AudioStreamPlayer", preload("audio/audio_stream_directory_player.gd"), preload("images/AudioStream.svg"))
	add_custom_type("AudioStreamPlaylistPlayer", "AudioStreamPlayer", preload("res://addons/playlists/audio/audio_stream_playlist_player.gd"), preload("images/AudioStream.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("AudioStreamDirectoryPlayer")
	remove_custom_type("AudioStreamPlaylistPlayer")
