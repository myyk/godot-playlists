@tool
extends EditorPlugin

const UpdaterConfig = preload("res://addons/plugin_updater/core/updater_config.gd")

func _enter_tree():
	var config = UpdaterConfig.get_user_config()
	_install_to_plugin(config.plugin_name)

func _exit_tree():
	pass

func _install_to_plugin(plugin_name: String):
	var err: Error = OK
	# Copy addons/plugin-updater/core as addons/<plugin_name>/generated/updater
	var source_path = "res://addons/plugin_updater/core/"
	var target_path = "res://addons/%s/generated/updater/" % plugin_name
	
	if DirAccess.dir_exists_absolute(target_path):
		err = OS.move_to_trash(ProjectSettings.globalize_path(target_path))
		if err != OK:
			push_error("plugin_updater: could not remove previous install, error = " + str(err))

	err = DirAccess.make_dir_recursive_absolute(target_path)
	if err != OK:
		push_error("plugin_updater: error making directory, error = " + str(err))

	#err = DirAccess.copy_absolute(source_path, target_path)
	err = _recursive_copy(source_path, target_path)
	if err != OK:
		push_error("plugin_updater: error copying files, error = " + str(err))

func _recursive_copy(from: String, to: String, chmod_flags: int = -1) -> Error:
	var from_dir = DirAccess.open(from)
	var to_dir = DirAccess.open(to)
	if from_dir:
		from_dir.list_dir_begin()
		var file_name = from_dir.get_next()
		while file_name != "":
			if from_dir.current_is_dir():
				print("Copying directory: " + file_name)
				if !to_dir.dir_exists(file_name):
					to_dir.make_dir(file_name)
				var err = _recursive_copy(from+file_name, to+file_name)
				if err != OK:
					return err
			else:
				print("Copying file: %s -> %s" % [from+file_name, to+file_name])
				var err = DirAccess.copy_absolute(from+file_name, to+file_name)
				if err != OK:
					return err
			file_name = from_dir.get_next()
			
		return OK
	else:
		return from_dir.get_open_error()
