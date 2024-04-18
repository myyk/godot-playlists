# GdUnit generated TestSuite
class_name AudioStreamPlaylistPlayerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/playlists/audio/audio_stream_playlist_player.gd'

const SONG1 = "res://example/audio/Beat Mekanik - Softly.mp3"
const SONG2 = "res://example/audio/Broke For Free - Day Bird.mp3"

var audio_player: AudioStreamPlaylistPlayer

func before_test():
	audio_player = auto_free(AudioStreamPlaylistPlayer.new())
	audio_player.files = [SONG1, SONG2]
	audio_player.continuous_play = true
	
	add_child(audio_player)

func after_test():
	remove_child(audio_player)

func test_play_next() -> void:
	audio_player.play_next()
	
	var last_song = audio_player.stream.resource_path
	audio_player.play_next()
	var next_song = audio_player.stream.resource_path

	assert(last_song != next_song, "The same song shouldn't place twice when there are 2 songs in the playlist")

	audio_player.play_next()
	var next_next_song = audio_player.stream.resource_path
	
	assert(next_song != next_next_song, "The playlist should have looped but without playing the same song twice")

func test_continuous_play() -> void:
	audio_player.play()
	
	var last_song = audio_player.stream.resource_path
	audio_player.finished.emit() # We can just fake this so that we don't have to wait for it to finish.
	var next_song = audio_player.stream.resource_path

	assert(last_song != next_song, "The next song should have started")
	assert(audio_player.playing, "A song should be playing")

func test_stop_and_restart() -> void:
	audio_player.play()
	
	var before_song = audio_player.stream.resource_path
	audio_player.stop()
	
	var after_song = audio_player.stream.resource_path

	assert(before_song == after_song, "The song should not move to the next")
	assert(!audio_player.playing, "A song should not be playing")

	audio_player.play()
	after_song = audio_player.stream.resource_path
	
	assert(before_song == after_song, "The same song should still be playing")
	assert(audio_player.playing, "A song should be playing")
