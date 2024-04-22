@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("AudioStreamDirectoryPlayer", "AudioStreamPlayer", preload("audio/audio_stream_directory_player.gd"), preload("images/AudioStream.svg"))
	add_custom_type("AudioStreamPlaylistPlayer", "AudioStreamPlayer", preload("res://addons/playlists/audio/audio_stream_playlist_player.gd"), preload("images/AudioStream.svg"))
	
	# Add auto-update functionality
	if Engine.is_editor_hint():
		Engine.set_meta("PlaylistsEditorPlugin", self)
		var update_tool: Node = load("res://addons/playlists/generated/updater/download_update_panel.tscn").instantiate()
		Engine.get_main_loop().root.call_deferred("add_child", update_tool)

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("AudioStreamDirectoryPlayer")
	remove_custom_type("AudioStreamPlaylistPlayer")

	if Engine.has_meta("PlaylistsEditorPlugin"):
		Engine.remove_meta("PlaylistsEditorPlugin")
