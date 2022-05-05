extends Control
tool


export var scene_task:PackedScene

var godot_ui:EditorInterface
var script_editor:ScriptEditor 
var items:Control
var color_accent:Color
# Godot icons: https://github.com/godotengine/godot/tree/master/editor/icons
var icons := {
	"Rename":false,
	"Script":false,
	"GuiUnchecked":false,
	"GuiChecked":false,
	"ZoomMore":false,
	"File":false,
	"CheckBox":false,
	"GuiScrollArrowRightHl":false,
	"GuiScrollArrowRight":false,
	"GuiTreeArrowRight":false,
	"GuiTreeArrowDown":false,
	"Add":false,
	"Remove":false,
	"PackedScene":false,
	"ArrowUp":false,
	"ArrowDown":false,
	"Clear":false,
}

onready var items_container:Control = find_node("ItemsContainer")
onready var btn_clear:Button = find_node("Clear")
onready var btn_rename:Button = find_node("Rename")
onready var btn_new_list:Button = find_node("NewList")
onready var btn_cur_list:OptionButton = find_node("CurList")
onready var dialog_new_list:AcceptDialog = find_node("DialogNewList")
onready var label_script:Label = find_node("LabelScript")


func set_godot_ui(plugin:EditorPlugin) -> void:
	var ui:EditorInterface = plugin.get_editor_interface()
	godot_ui = ui
	script_editor = ui.get_script_editor()
	script_editor.connect("editor_script_changed",self,"on_editor_script_changed")
	
	for icon in icons:
		icons[icon] = godot_ui.get_base_control().get_icon(icon,"EditorIcons")
	
	var editor_settings = plugin.get_editor_interface().get_editor_settings()
	color_accent = editor_settings.get_setting("interface/theme/accent_color")


func on_editor_script_changed(script:Script):
	if script:
		label_script.set_text(script.resource_path.get_file())


func _ready() -> void:
	# Buttons
	btn_clear.icon = icons.Clear
	btn_new_list.icon = icons.Add

	# OptionButton - Lists
	# Signals
	btn_cur_list.connect("item_selected",self,"open_list")
	# Get all lists from the save folder
	var dir = Directory.new()
	var path = "res://addons/faves/save"
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var title = file_name.trim_suffix(".tscn")
				btn_cur_list.add_item(title)
			file_name = dir.get_next()
	else:
		print("Faves Plugin: An error occurred when trying to access the load path: ",path)
	
	# Get the last opened list from a save file
	var file = File.new()
	file.open("res://addons/faves/saved_list_name.sav", File.READ)
	var last_list:String = file.get_as_text()
	file.close()
	
	# Select the last opened list on the OptionButton, then load it
	var list_found := false
	for idx in btn_cur_list.get_item_count():
		if btn_cur_list.get_item_text(idx) == last_list:
			btn_cur_list.select(idx)
			list_found = true
			break
	
	# No lists found? Create one
	if not list_found:
		create_new_list(last_list)
		btn_cur_list.add_item(last_list)
		btn_cur_list.select(0)
	
	load_list(last_list)
	
	# Update script label
	on_editor_script_changed(script_editor.get_current_script())


func on_task_added(emitter:Control):
	var task = scene_task.instance()
	items.add_child_below_node(emitter,task)
	task.owner = items
	task.set_icons(icons)


func open_resource(resource):
	if resource is Script:
		godot_ui.set_main_screen_editor("Script")
		godot_ui.edit_script(resource,-1,0,true)
	elif resource is PackedScene:
		godot_ui.set_main_screen_editor("2D")
		godot_ui.open_scene_from_path(resource.resource_path)
#		godot_ui.reload_scene_from_path(resource.resource_path)
	else:
		godot_ui.edit_resource(resource)


func _on_Clear_pressed() -> void:
	for item in items.get_children():
		for task in item.get_children():
			if task is FavesTask and task.done:
				task.queue_free()


func save_list_current():
	var list_name = btn_cur_list.get_item_text(btn_cur_list.selected)
	save_list(list_name)


func save_list(list_name):
	var packed_scene = PackedScene.new()
	packed_scene.pack(items)
	var path = str("res://addons/faves/save/",list_name,".tscn")
	ResourceSaver.save(path, packed_scene)


func load_list(list_name):
	var path = str("res://addons/faves/save/",list_name,".tscn")
	var list = load(path).instance()

	if items:
		items.queue_free()
	items_container.add_child(list)
	items = list
	items.my_name = list_name
	items.dock = self
	for node in get_tree().get_nodes_in_group("faves_dock_refs"):
		node.dock = self
		node.set_icons(icons)


func open_list(idx):
	save_list(items.my_name)
	var list_name = btn_cur_list.get_item_text(idx)
	load_list(list_name)


func _on_NewList_pressed() -> void:
	dialog_new_list.popup_centered()
	dialog_new_list.get_node("ListName").text = ""
	dialog_new_list.get_node("ListName").grab_focus()


func _on_DialogNewList_confirmed() -> void:
	var list_name:String = dialog_new_list.get_node("ListName").text
	btn_cur_list.add_item(list_name)
	var last_index:int = btn_cur_list.get_item_count() -1
	
	save_list_current()
	items.queue_free()
	
	btn_cur_list.select(last_index)
	create_new_list(list_name)


func create_new_list(list_name:String):
	var list_fresh = load("res://addons/faves/dock/list_fresh.tscn").instance()
	items_container.add_child(list_fresh)
	items = list_fresh
	items.my_name = list_name
	items.dock = self
	save_list(list_name)



func _on_ListName_text_entered(new_text: String) -> void:
	_on_DialogNewList_confirmed()
	dialog_new_list.visible = false
