extends HBoxContainer

@onready var selection = $"../../../Selection"


func _on_delete_button_pressed():
	selection.delete_selected_profile()


func _on_rename_button_pressed():
	selection.rename_selected_profile()
