# Playlist _for Godot 4_

Godot Playlist is a small library for loading large sets of resources such as AudioStreams in a way that uses minimal memory. It's useful for playing playlists of songs while only maintaining one song in memory at a time.

You can install it via the Asset Library or [downloading a copy](https://github.com/myyk/godot-playlist/archive/refs/heads/main.zip) from GitHub.

## Usage

Either add an `AudioStreamPlaylistPlayer` or `AudioStreamDirectoryPlayer` to your scene to continuously play a playlist in your project.

`AudioStreamPlaylistPlayer` - Can take filepaths for the playlist.

`AudioStreamDirectoryPlayer` - Can take a directory and extensions and create a playlist from that.

## Version

Godot Playlist **requires at least Godot 4.2**.

## License
This project is licensed under the terms of the [MIT license](https://github.com/myyk/godot-playlist/blob/main/LICENSE).
