# Playlists _for Godot 4_

Godot Playlists is a small library for loading large sets of resources such as AudioStreams in a way that uses minimal memory. It's useful for playing playlists of songs while only maintaining one song in memory at a time.

You can install it via the Asset Library or [downloading a copy](https://github.com/myyk/godot-playlists/archive/refs/heads/main.zip) from GitHub.

## Usage

Either add an `AudioStreamPlaylistPlayer` or `AudioStreamDirectoryPlayer` to your scene to continuously play a playlist in your project.

`AudioStreamPlaylistPlayer` - Can take filepaths for the playlist.

`AudioStreamDirectoryPlayer` - Can take a directory and extensions and create a playlist from that.

### Settings

These settings are on both:

- `is_shuffled` - When set to true, the playback order is shuffled. If there are more than 2 tracks, the same track won't be played twice. There will be no repeats until every track has played once.
- `continuous_play` - When set to true, it keep playing tracks one after another.

## Example

Take a look at the small scene in [ExampleRandomPlaylist.tscn](example/ExampleRandomPlaylist.tscn) to see how you can use it. This example project has a small playlist and a button that you can press to skip to the next song.

## Version

Godot Playlist **requires at least Godot 4.2**.

## License
This project is licensed under the terms of the [MIT license](https://github.com/myyk/godot-playlists/blob/main/LICENSE).
