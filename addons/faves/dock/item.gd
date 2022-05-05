tool
extends Control

signal task_added(emitter)

export var resource:Resource 
export var collapsed:bool = false
export var extension:String
export var my_name:String

onready var btn_main:Button = find_node("Main")
onready var btn_expand:Button = find_node("Expand")
onready var btn_new_task:Button = find_node("Task")
onready var btn_remove:Button = find_node("Remove")
onready var btn_move_up:Button = find_node("MoveUp")
onready var btn_move_down:Button = find_node("MoveDown")

var dock:Control


var icons:Dictionary


func set_data(file_path:String):
	resource = load(file_path)
	my_name = file_path.get_file()


func set_icons(_icons):
	icons = _icons
	btn_new_task.icon = icons.Add
	btn_move_up.icon = icons.ArrowUp
	btn_move_down.icon = icons.ArrowDown
	
	if resource is Script:
		btn_main.icon = icons.Script
	elif resource is PackedScene:
		btn_main.icon = icons.PackedScene

	set_collapsed_icons()
	btn_remove.icon = icons.Remove


func _ready() -> void:
	btn_new_task.connect("pressed",self,"on_Task_pressed")
	btn_expand.connect("toggled",self,"on_Expand_toggled")
	btn_main.connect("pressed",self,"on_Main_pressed")
	btn_remove.connect("pressed",self,"on_Remove_pressed")
	btn_move_up.connect("pressed",self,"on_Move_Up_pressed")
	btn_move_down.connect("pressed",self,"on_Move_Down_pressed")
	
	if collapsed:
		collapse(true)
	else:
		collapse(false)

	btn_main.text = my_name


func on_Main_pressed():
	dock.open_resource(resource)


func on_Remove_pressed():
	queue_free()

func on_Task_pressed() -> void:
	var task:FavesTask = load("res://addons/faves/dock/task.tscn").instance()
	collapse(false)
	add_child_below_node($Base,task)
	task.owner = owner
	task.set_icons(dock.icons)
	task.force_edit()


func on_Expand_toggled(pressed:bool) -> void:
	collapse(pressed)


func collapse(true_or_false:bool):
	btn_expand.pressed = true_or_false
	collapsed = true_or_false
	set_collapsed_icons()
	show_tasks(!true_or_false)


func set_collapsed_icons():
	if not icons.empty():
		if collapsed:
			btn_expand.icon = icons.GuiTreeArrowRight
		else:
			btn_expand.icon = icons.GuiTreeArrowDown


func show_tasks(true_or_false:bool):
	for child in get_children():
		if child.name != "Base":
			child.visible = true_or_false


func on_Move_Down_pressed():
	Move(1)


func on_Move_Up_pressed():
	Move(-1)


func Move(amount:int):
	var new_position = get_index() + amount
	if new_position < 1:
		new_position = 1
	get_parent().move_child(self,new_position)
