extends Control

@onready var selection = $"../../../../../../Selection"
@onready var name_label = $"Name"

func _on_check_button_toggled(button_pressed):
	if not name_label: return
	if button_pressed:
		selection.enable_mod(name_label.text)
	else:
		selection.disable_mod(name_label.text)
