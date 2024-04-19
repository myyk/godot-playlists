@tool
extends Node

### User config

static func get_user_config() -> Dictionary:
	var user_config: Dictionary = {
		check_for_updates = true,
	}

	#if FileAccess.file_exists(DialogueConstants.USER_CONFIG_PATH):
		#var file: FileAccess = FileAccess.open(DialogueConstants.USER_CONFIG_PATH, FileAccess.READ)
		#user_config.merge(JSON.parse_string(file.get_as_text()), true)

	return user_config

static func get_user_value(key: String, default = null):
	return get_user_config().get(key, default)
