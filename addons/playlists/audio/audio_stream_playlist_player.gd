@tool
class_name AudioStreamPlaylistPlayer
extends AudioStreamPlayer

## An AudioStreamPlayer that has been extended to be able to play a plalist of
## audio files without keeping them all loaded in memory as once like would
## happen by using an AudioStreamRandomizer.

@export var files: Array: ## The audio file paths in the playlist.
	set(value):
		files = value
		_reshuffle()

## When set to true, the playback order is shuffled. If there are more than 2 tracks, the same track won't be played twice. There will be no repeats until every track has played once.
@export var is_shuffled: bool = false:
	set(value):
		is_shuffled = value
		_reshuffle()

## When set to true, it keep playing tracks one after another.
@export var continuous_play: bool = true

var current_index: int

func _ready():
	finished.connect(_finished_track)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Waiting to stop the stream...")
		stop()
		if stream:
			stream = null
		await get_tree().create_timer(0.2).timeout
		get_tree().quit() # default behavior

func _reshuffle():
	if Engine.is_editor_hint():
		return
	
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
