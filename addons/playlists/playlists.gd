@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	
	# Add auto-update functionality
	if Engine.is_editor_hint():
		Engine.set_meta("PlaylistsEditorPlugin", self)
		var update_tool: Node = load("res://addons/playlists/generated/updater/download_update_panel.tscn").instantiate()
		Engine.get_main_loop().root.call_deferred("add_child", update_tool)

func _exit_tree():
	# Clean-up of the plugin goes here.
	
	if Engine.has_meta("PlaylistsEditorPlugin"):
		Engine.remove_meta("PlaylistsEditorPlugin")
