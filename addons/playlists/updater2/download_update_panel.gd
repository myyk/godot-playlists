@tool
extends Window

## Updater heaviliy inspired by GDUnit4's updater, but decoupled completely from GDUnit. Also did not
## include all the patching that included since it seemed to complicated to include for most projects.

#TODO: read this from somewhere
var config = UpdaterConfig.get_user_config()

var spinner_icon = "res://addons/%s/updater2/spinner.tres" % config.plugin_name

# Using this style of import avoids polluting user's namespaces
const UpdaterConfig = preload("updater_config.gd")
const HttpClient = preload("updater_http_client.gd")
const MarkDownReader = preload("updater_markdown_reader.gd")

const TEMP_FILE_NAME = "user://temp.zip"

@onready var _md_reader: MarkDownReader = MarkDownReader.new()
@onready var _http_client: HttpClient = $HttpClient
@onready var _header: Label = $Panel/GridContainer/PanelContainer/header
@onready var _content: RichTextLabel = $Panel/GridContainer/PanelContainer2/ScrollContainer/MarginContainer/content
@onready var _update_button: Button = $Panel/GridContainer/Panel/HBoxContainer/update

var _download_zip_url: String
var _editor_interface: EditorInterface

func _ready():
	hide()
	_http_client.github_repo = config.github_repo
	
	var plugin :EditorPlugin = Engine.get_meta(config.editor_plugin_meta)
	_editor_interface = plugin.get_editor_interface()
	
	# wait a bit to allow the editor to initialize itself
	await Engine.get_main_loop().create_timer(float(config.secs_before_check_for_update)).timeout
	
	_check_for_updater()

func _check_for_updater():
	var response = await _http_client.request_latest_version()
	if response.code() != 200:
		push_warning("Update information cannot be retrieved from GitHub! \n %s" % response.response())
		return
	var latest_version := extract_latest_version(response)
	var current_version := extract_current_version()
	
	# if same version exit here no update need
	if latest_version.is_greater(current_version):
		_download_zip_url = extract_zip_url(response)
		_header.text = "Current version '%s'. A new version '%s' is available" % [current_version, latest_version]
		await show_update()

func show_update() -> void:
	message_h4("\n\n\nRequest release infos ... [img=24x24]%s[/img]" % spinner_icon, Color.SNOW)
	popup_centered_ratio(.5)
	prints("Scanning for %s Update ..." % config.plugin_name)
	var content :String

	var response: HttpClient.HttpResponse = await _http_client.request_releases()
	if response.code() == 200:
		content = await extract_releases(response, extract_current_version())
	else:
		message_h4("\n\n\nError checked request available releases!", Color.RED)
		return

	# finally force rescan to import images as textures
	if Engine.is_editor_hint():
		await rescan()
	message(content, Color.DODGER_BLUE)
	_update_button.set_disabled(false)

func rescan() -> void:
	if Engine.is_editor_hint():
		if OS.is_stdout_verbose():
			prints(".. reimport release resources")
		var fs := _editor_interface.get_resource_filesystem()
		fs.scan()
		while fs.is_scanning():
			if OS.is_stdout_verbose():
				progress_bar(fs.get_scanning_progress() * 100 as int)
			await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().create_timer(1).timeout

func extract_current_version() -> UpdaterSemVer:
	var config_file = ConfigFile.new()
	config_file.load('addons/%s/plugin.cfg' % config.plugin_name)
	return UpdaterSemVer.parse(config_file.get_value('plugin', 'version'))

static func extract_latest_version(response: HttpClient.HttpResponse) -> UpdaterSemVer:
	var body :Array = response.response()
	return UpdaterSemVer.parse(body[0]["name"])

static func extract_zip_url(response: HttpClient.HttpResponse) -> String:
	var body :Array = response.response()
	return body[0]["zipball_url"]

func extract_releases(response: HttpClient.HttpResponse, current_version) -> String:
	await get_tree().process_frame
	var result := ""
	for release in response.response():
		if UpdaterSemVer.parse(release["tag_name"]).equals(current_version):
			break
		var release_description :String = release["body"]
		result += await _md_reader.to_bbcode(release_description)
	return result

func message_h4(message :String, color :Color, clear := true) -> void:
	if clear:
		_content.clear()
	_content.append_text("[font_size=16]%s[/font_size]" % _colored(message, color))

func message(message :String, color :Color) -> void:
	_content.clear()
	_content.append_text(_colored(message, color))

func progress_bar(p_progress :int, p_color :Color = Color.POWDER_BLUE):
	if p_progress < 0:
		p_progress = 0
	if p_progress > 100:
		p_progress = 100
	printraw("scan [%-50s] %-3d%%\r" % ["".lpad(int(p_progress/2.0), "#").rpad(50, "-"), p_progress])

func _colored(message :String, color :Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), message]

func _on_disable_updates_toggled(toggled_on):
	# TODO: Store a setting somewhere
	pass

func _on_update_pressed():
	hide()
	_update_button.set_disabled(true)
	
	#TODO: How do I give the plugins a hook to perform actions before updating?
	
	#TODO: Perform the update, maybe use the simpler approach from the dialog plugin
	var updater_http_request = HTTPRequest.new()
	updater_http_request.accept_gzip = true
	add_child(updater_http_request)

	updater_http_request.request_completed.connect(_on_http_request_request_completed)
	updater_http_request.request(_download_zip_url)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		message_h4("\n\n\nError downloading update!", Color.RED)
		return

	# Save the downloaded zip
	var zip_file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	zip_file.store_buffer(body)
	zip_file.close()

	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/%s" % config.plugin_name))

	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()

	var base_path = files[1]
	# Remove archive folder
	files.remove_at(0)
	# Remove assets folder
	files.remove_at(0)

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
		else:
			var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
			file.store_buffer(zip_reader.read_file(path))

	zip_reader.close()
	DirAccess.remove_absolute(TEMP_FILE_NAME)

	#TODO: Show that we successfully updated

func _on_close_pressed():
	hide()

func _on_content_meta_clicked(meta :String):
	var properties = str_to_var(meta)
	if properties.has("url"):
		OS.shell_open(properties.get("url"))

func _on_content_meta_hover_started(meta :String):
	var properties = str_to_var(meta)
	if properties.has("tool_tip"):
		_content.set_tooltip_text(properties.get("tool_tip"))

func _on_content_meta_hover_ended(meta):
	_content.set_tooltip_text("")
