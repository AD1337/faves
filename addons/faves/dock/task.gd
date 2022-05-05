tool
class_name FavesTask
extends HBoxContainer

export var label:String = ""
export var done:bool = false

var dock:Control
var icons := {}

func _ready() -> void:
	$Label.text = label
#	set_icons(dock.icons)
	if done:
		$Check.pressed = true


func _on_Label_text_changed(new_text: String) -> void:
	label = new_text
	$Label.hint_tooltip = new_text


func set_icons(_icons):
	icons = _icons
	$Line.icon = icons.GuiScrollArrowRight


func _on_Check_toggled(pressed: bool) -> void:
	done = pressed
	$Label.editable = !pressed


func _on_Label_focus_exited() -> void:
	$Label.caret_position = 0


func force_edit():
	#print("force edit")
	$Label.grab_focus()
