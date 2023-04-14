extends CanvasLayer

@onready var color_rect = $"ColorRect"

func _ready():
	get_tree().get_root().connect("size_changed", set_size)
	set_size()
	get_tree().paused = true


func set_size():
	var screen_size = get_viewport().get_visible_rect().size
	color_rect.size = screen_size


func _on_continue_button_pressed():
	visible = false
	get_tree().paused = false
	Gmm.reload_mods()
