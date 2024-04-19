class_name UpdaterPatch
extends RefCounted

const PATCH_VERSION = "patch_version"

var _version :UpdaterVersion


func _init(version_ :UpdaterVersion):
	_version = version_


func version() -> UpdaterVersion:
	return _version


# this function needs to be implement
func execute() -> bool:
	push_error("The function 'execute()' is not implemented at %s" % self)
	return false
