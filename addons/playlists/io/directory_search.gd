class_name DirectorySearch
extends RefCounted

# Search for image files in the specified directory
func find_in_directory(directory_path: String, extensions: Array[String]) -> Array:
	if !directory_path.ends_with('/'):
		directory_path += '/'
	
	var image_paths = []
	var dir: DirAccess = DirAccess.open(directory_path)
	if dir:
		image_paths.append_array(dir.get_files())

	# This is a bizarre little piece of code is because of the way imports work: https://forum.godotengine.org/t/cannot-traverse-asset-directory-in-android/20496/2
	var filtered_paths = []
	for next in image_paths:
		var filename = next.replace('.import', '') # <--- remove the .import
		for next_extension in extensions:
			if !next_extension.begins_with('.'):
				next_extension = '.' + next_extension
			
			if filename.ends_with(next_extension):
				filtered_paths.append(filename)
	
	# make the full path
	var full_paths: Array[String] = []
	for next in filtered_paths:
		full_paths.append(directory_path + next)
	
	return full_paths
