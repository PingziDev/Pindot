## 插件的注册类
##
## 用于在启动插件时注册各种数据, 在插件退出时注销
@tool
extends EditorPlugin

const EDITOR = preload("res://addons/pindot/editor/pindot_config.tscn")

## 全局Singleton
const AUTOLOADS := {"Pindot": "res://addons/pindot/pindot.gd"}

## 框架的项目配置数据,在"项目-Pindot"中配置,Array[PropertyInfo]
const PROJECT_SETTINGS := [
	# 框架配置文件路径
	{
		"name": "pindot/config_file",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,  # 默认用法（存储和编辑器）。
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.tres",
		"default_value": DEFULT_CONFIG_DEV,
		"description": "Pindot config file path",
		"doc": "Pindot config file path",
	},
]

## 默认配置文件
const DEFULT_CONFIG_DEV = "res://addons/pindot/config/pindot_config_dev.tres"
const DEFULT_CONFIG_BUILD = "res://addons/pindot/config/pindot_config_build.tres"

var main_panel_instance: Control


func _enter_tree() -> void:
	# #	Panle在dock中
	# main_panel_instance =	EDITOR.instantiate()
	# add_control_to_dock(DOCK_SLOT_LEFT_UL, main_panel_instance)

	# Panel在Main Screen
	# main_panel_instance = EDITOR.instantiate()
	# EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# _make_visible(false)

	print("\n===== PINDOT START LOADING =====")

	# 添加框架的项目配置属性
	print("\n----- PROJECT SETTINGS -----")
	for propertyinfo in PROJECT_SETTINGS:
		_add_project_setting(propertyinfo)
		print("Setting Name:      ", propertyinfo.name)
		print("Default Value:    ", str(propertyinfo.default_value))
		print("---------------------------")

	# var setting_name :='test/testaname'
	# var value='sdfsdjlkfdsjlf'
	# if !ProjectSettings.has_setting(setting_name):
	# 	ProjectSettings.set_setting(setting_name,value)
	# ProjectSettings.set_initial_value(setting_name,value)

	# 添加全局单例
	print("\n----- AUTOLOADS -----")
	for autoload in AUTOLOADS:
		print("Loaded Singleton:  ", autoload)
		add_autoload_singleton(autoload, AUTOLOADS[autoload])

	print("\n===== PINDOT LOADED SUCCESSFULLY! =====\n")


func _exit_tree() -> void:
	print("\n=====  REMOVING PROJECT SETTINGS =====")

	# 移除全局单例
	print("\n----- AUTOLOADS -----")
	for autoload in AUTOLOADS:
		print("Removed Singleton: ", autoload)
		remove_autoload_singleton(autoload)

	# #	Panle在dock中
	# remove_control_from_docks(main_panel_instance)
	# main_panel_instance.free()

	# 移除框架的项目配置属性
	print("\n----- REMOVING PROJECT SETTINGS -----")
	for propertyinfo in PROJECT_SETTINGS:
		ProjectSettings.clear(propertyinfo.name)
		print("Removed Setting:   ", propertyinfo.name)

	print("\n===== PINDOT UNLOADED SUCCESSFULLY! =====\n")


## 添加project_setting属性
func _add_project_setting(propertyinfo: Dictionary) -> void:
	ProjectSettings.set_setting(propertyinfo.name, propertyinfo.default_value)
	ProjectSettings.add_property_info(propertyinfo)
	ProjectSettings.set_as_basic(propertyinfo.name, true)
	ProjectSettings.save()

# func _has_main_screen() -> bool:
# 	return true

# func _make_visible(visible: bool) -> void:
# 	if main_panel_instance:
# 		main_panel_instance.visible = visible

# func _get_plugin_name() -> String:
# 	return "Pindot"

# func _get_plugin_icon() -> Texture2D:
# 	# return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
# 	return load("res://icon.svg")
