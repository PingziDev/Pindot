## 用于配置Pindot框架的全局配置
@tool
extends EditorPlugin

const EDITOR = preload("res://addons/pindot/editor/main_panel.tscn")
var main_panel_instance:Control

func _enter_tree():
    # 添加Panle到编辑器
	main_panel_instance = EDITOR.instantiate()
    add_control_to_dock(DOCK_SLOT_LEFT_UL, main_panel_instance)
	# EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
    # if main_panel_instance:
	    # main_panel_instance.visible = false


func _exit_tree():
	# if main_panel_instance:
        # main_panel_instance.queue_free()
    remove_control_from_docks(main_panel_instance)
    main_panel_instance.free()


func _has_main_screen():
	return true


func _make_visible(visible):
	pass


func _get_plugin_name():
	return "Main Screen Plugin"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
