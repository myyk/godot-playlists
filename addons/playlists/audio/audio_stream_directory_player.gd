@tool
class_name AudioStreamDirectoryPlayer
extends AudioStreamPlayer

# TODO: Make this move to the next track automatically
# TODO: add a randomize: bool variable

@export_dir var directory: String: ## Directory of the where the audio files are located. ex: "res://art/"
	set(value):
		directory = value
		_update()
		
@export var extensions: Array[String]: ## The file extensions to include of audio files.
	set(value):
		extensions = value
		_update()

var files: Array
var current_index: int

func _update():
	if !directory or !extensions or extensions.is_empty():
		return
	
	var dir_search = DirectorySearch.new()
	files = dir_search.find_in_directory(directory, extensions)
	_load_stream()

func randomize():
	if !files or files.is_empty():
		current_index = 0
		return
	
	current_index = randi()%files.size()
	var was_playing = playing
	_load_stream()
	if was_playing:
		play()

func _load_stream():
	stream = load(files[current_index])
