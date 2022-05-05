tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("res://addons/faves/dock/dock.tscn").instance()
	dock.set_godot_ui(self)
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

func save_external_data():
	dock.save_list_current()
	var my_name = dock.items.my_name
	if my_name != "" and my_name != null:
		var file = File.new()
		file.open("res://addons/faves/save/save.cfg", File.WRITE)
		file.store_string(dock.items.my_name)
		file.close()
		
