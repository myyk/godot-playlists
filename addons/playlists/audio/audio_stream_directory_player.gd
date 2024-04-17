@tool
class_name AudioStreamDirectoryPlayer
extends AudioStreamPlaylistPlayer

## An AudioStreamPlaylistPlayer that has been extended to be able to play a
## directory of audio files without keeping them all loaded in memory as once
## like would happen by using an AudioStreamRandomizer.

@export_dir var directory: String: ## Directory of the where the audio files are located. ex: "res://art/"
	set(value):
		directory = value
		_update()
		
@export var extensions: Array[String]: ## The file extensions to include of audio files.
	set(value):
		extensions = value
		_update()

func _update():
	if !directory or !extensions or extensions.is_empty():
		return
	
	var dir_search = DirectorySearch.new()
	files = dir_search.find_in_directory(directory, extensions)
	current_index = 0
