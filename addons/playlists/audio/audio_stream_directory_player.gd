@tool
class_name AudioStreamDirectoryPlayer
extends AudioStreamPlayer

## An AudioStreamPlayer that has been extended to be able to play a directory of
## audio files without keeping them all loaded in memory as once like would
## happen by using an AudioStreamRandomizer. This is useful for music playlists.

@export_dir var directory: String: ## Directory of the where the audio files are located. ex: "res://art/"
	set(value):
		directory = value
		_update()
		
@export var extensions: Array[String]: ## The file extensions to include of audio files.
	set(value):
		extensions = value
		_update()

## When set to true, the playback order is shuffled. If there are more than 2 tracks, the same track won't be played twice. There will be no repeats until every track has played once.
@export var is_shuffled: bool = false

## When set to true, it keep playing tracks one after another.
@export var continuous_play: bool = true

var files: Array
var current_index: int

func _ready():
	finished.connect(_finished_track)

func _update():
	if !directory or !extensions or extensions.is_empty():
		return
	
	var dir_search = DirectorySearch.new()
	files = dir_search.find_in_directory(directory, extensions)
	current_index = 0
	
	if is_shuffled:
		files.shuffle()
	
	if !files.is_empty():
		_load_stream()

## Play a the next track.
func play_next():
	if !files or files.is_empty():
		current_index = 0
		return
	
	current_index = (current_index+1) % files.size()
	if current_index == 0 && files.size() > 1:
		# Shuffle until there's not a repeat
		var current_track = files[-1]
		files.shuffle()
		while current_track == files[0]:
			files.shuffle()
	
	var was_playing = playing
	_load_stream()
	if was_playing:
		play()

func _load_stream():
	stream = load(files[current_index])

func _finished_track():
	if continuous_play:
		play_next()
		play()
