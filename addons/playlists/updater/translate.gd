extends Node

static func translate(string: String) -> String:
	var base_path = new().get_script().resource_path.get_base_dir()

	var language: String = TranslationServer.get_tool_locale()
	var translations_path: String = "%s/l10n/%s.po" % [base_path, language]
	var fallback_translations_path: String = "%s/l10n/%s.po" % [base_path, TranslationServer.get_tool_locale().substr(0, 2)]
	var en_translations_path: String = "%s/l10n/en.po" % base_path
	var translations: Translation = load(translations_path if FileAccess.file_exists(translations_path) else (fallback_translations_path if FileAccess.file_exists(fallback_translations_path) else en_translations_path))
	return translations.get_message(string)
