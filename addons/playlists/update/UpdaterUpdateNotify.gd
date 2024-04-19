@tool
extends Window

signal request_completed(response)

const GdMarkDownReader = preload("res://addons/playlists/update/GdMarkDownReader.gd")
const UpdaterUpdateClient = preload("res://addons/playlists/update/UpdaterUpdateClient.gd")
const spinner_icon := "res://addons/gdUnit4/src/ui/assets/spinner.tres"

@onready var _md_reader :GdMarkDownReader = GdMarkDownReader.new()
@onready var _update_client :UpdaterUpdateClient = $UpdateClient
@onready var _header :Label = $Panel/GridContainer/PanelContainer/header
@onready var _update_button :Button = $Panel/GridContainer/Panel/HBoxContainer/update
@onready var _close_button :Button = $Panel/GridContainer/Panel/HBoxContainer/close
@onready var _content :RichTextLabel = $Panel/GridContainer/PanelContainer2/ScrollContainer/MarginContainer/content

var plugin :EditorPlugin 

var _debug_mode := false

var _editor_interface :EditorInterface
var _patcher :UpdaterPatcher = UpdaterPatcher.new()
var _current_version := UpdaterVersion.current()
var _available_versions :Array
var _download_zip_url :String

const PLUGIN_NAME = "playlists"
const SECS_BEFORE_STARTING = 5

func _ready():
	_update_client.github_repo = "myyk/godot-playlists"
	
	var plugin :EditorPlugin = Engine.get_meta("PlaylistsEditorPlugin")
	_editor_interface = plugin.get_editor_interface()
	_update_button.disabled = true
	_md_reader.set_http_client(_update_client)
	GdUnitFonts.init_fonts(_content)
	await request_releases()

	_patcher.base_dir = "res://addons/%s/patches/" % PLUGIN_NAME

func request_releases() -> void:
	if _debug_mode:
		_header.text = "A new version 'v4.1.0_debug' is available"
		await show_update()
		return

	# wait a bit to allow the editor to initialize itself
	await Engine.get_main_loop().create_timer(SECS_BEFORE_STARTING).timeout
	var response :UpdaterUpdateClient.HttpResponse = await _update_client.request_latest_version()
	if response.code() != 200:
		push_warning("Update information cannot be retrieved from GitHub! \n %s" % response.response())
		return
	var latest_version := extract_latest_version(response)
	print(response.response())
	prints(latest_version, "<- latest version, current version ->", _current_version)
	# if same version exit here no update need
	if latest_version.is_greater(_current_version):
		_patcher.scan(_current_version)
		_header.text = "Current version '%s'. A new version '%s' is available" % [_current_version, latest_version]
		_download_zip_url = extract_zip_url(response)
		await show_update()


func _colored(message :String, color :Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), message]


func message_h4(message :String, color :Color, clear := true) -> void:
	if clear:
		_content.clear()
	_content.append_text("[font_size=16]%s[/font_size]" % _colored(message, color))


func message(message :String, color :Color) -> void:
	_content.clear()
	_content.append_text(_colored(message, color))


func _process(_delta):
	if _content != null and _content.is_visible_in_tree():
		_content.queue_redraw()


func show_update() -> void:
	message_h4("\n\n\nRequest release infos ... [img=24x24]%s[/img]" % spinner_icon, Color.SNOW)
	popup_centered_ratio(.5)
	prints("Scanning for %s Update ..." % PLUGIN_NAME)
	var content :String
	if _debug_mode:
		var template = FileAccess.open("res://addons/gdUnit4/test/update/resources/markdown.txt", FileAccess.READ).get_as_text()
		content = await _md_reader.to_bbcode(template)
	else:
		var response :UpdaterUpdateClient.HttpResponse = await _update_client.request_releases()
		if response.code() == 200:
			content = await extract_releases(response, _current_version)
		else:
			message_h4("\n\n\nError checked request available releases!", Color.RED)
			return

	# finally force rescan to import images as textures
	if Engine.is_editor_hint():
		await rescan()
	message(content, Color.DODGER_BLUE)
	_update_button.set_disabled(false)


static func extract_latest_version(response :UpdaterUpdateClient.HttpResponse) -> UpdaterVersion:
	var body :Array = response.response()
	return UpdaterVersion.parse(body[0]["name"])


static func extract_zip_url(response :UpdaterUpdateClient.HttpResponse) -> String:
	var body :Array = response.response()
	return body[0]["zipball_url"]


func extract_releases(response :UpdaterUpdateClient.HttpResponse, current_version) -> String:
	await get_tree().process_frame
	var result := ""
	for release in response.response():
		if UpdaterVersion.parse(release["tag_name"]).equals(current_version):
			break
		var release_description :String = release["body"]
		result += await _md_reader.to_bbcode(release_description)
	return result


func rescan() -> void:
	if Engine.is_editor_hint():
		if OS.is_stdout_verbose():
			prints(".. reimport release resources")
		var fs := _editor_interface.get_resource_filesystem()
		fs.scan()
		while fs.is_scanning():
			if OS.is_stdout_verbose():
				progressBar(fs.get_scanning_progress() * 100 as int)
			await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().create_timer(1).timeout


func progressBar(p_progress :int, p_color :Color = Color.POWDER_BLUE):
	if p_progress < 0:
		p_progress = 0
	if p_progress > 100:
		p_progress = 100
	printraw("scan [%-50s] %-3d%%\r" % ["".lpad(int(p_progress/2.0), "#").rpad(50, "-"), p_progress])


func _on_update_pressed():
	_update_button.set_disabled(true)
	# close all opend scripts before start the update
	if not _debug_mode:
		ScriptEditorControls.close_open_editor_scripts()
	# copy update source to a temp because the update is deleting the whole gdUnit folder
	DirAccess.make_dir_absolute("res://addons/.gdunit_update")
	DirAccess.copy_absolute("res://addons/gdUnit4/src/update/UpdaterUpdate.tscn", "res://addons/.gdunit_update/UpdaterUpdate.tscn")
	DirAccess.copy_absolute("res://addons/gdUnit4/src/update/UpdaterUpdate.gd", "res://addons/.gdunit_update/UpdaterUpdate.gd")
	var source := FileAccess.open("res://addons/gdUnit4/src/update/UpdaterUpdate.tscn", FileAccess.READ)
	var content := source.get_as_text().replace("res://addons/gdUnit4/src/update/UpdaterUpdate.gd", "res://addons/.gdunit_update/UpdaterUpdate.gd")
	var dest := FileAccess.open("res://addons/.gdunit_update/UpdaterUpdate.tscn", FileAccess.WRITE)
	dest.store_string(content)
	hide()
	var update = load("res://addons/.gdunit_update/UpdaterUpdate.tscn").instantiate()
	update.setup(_editor_interface, _update_client, _download_zip_url)
	Engine.get_main_loop().root.add_child(update)
	update.popup_centered()


func _on_show_next_toggled(enabled :bool):
	GdUnitSettings.set_update_notification(enabled)


func _on_cancel_pressed():
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