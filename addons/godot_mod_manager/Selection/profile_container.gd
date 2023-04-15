extends HBoxContainer

@onready var selection = $"../../../Selection"


func _on_delete_button_pressed():
	selection.delete_selected_profile()


func _on_rename_button_pressed():
	selection.rename_selected_profile()


func _on_select_all_button_pressed():
	selection.select_all()


func _on_deselect_all_button_pressed():
	selection.deselect_all()
