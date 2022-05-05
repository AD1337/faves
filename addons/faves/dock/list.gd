tool
extends VBoxContainer

signal moved(item, to_item, shift)

var my_name:String = ""


var dock:Control


func set_dock(_dock):
	dock = _dock


func can_drop_data(position, data):
	if data is Dictionary:
		if data.type == "files":
			return true


func drop_data(position, data):
	print(position)
	var tutorial = get_node_or_null("Tutorial")
	if tutorial:
		tutorial.free()
	for file in data.files:
		var item = load("res://addons/faves/dock/item.tscn").instance()
		item.dock = dock
		item.set_data(file)
		add_child(item)
		item.set_icons(dock.icons)
		item.owner = self
		if position.y < self.rect_size.y / 2:
			move_child(item,1)

