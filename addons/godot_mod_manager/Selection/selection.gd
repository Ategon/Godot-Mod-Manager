extends CanvasLayer

@onready var profile_container = preload("res://addons/godot_mod_manager/Selection/profile_container.tscn")
@onready var mod_entry_scene = preload("res://addons/godot_mod_manager/Selection/mod_entry.tscn")

@onready var color_rect = $"ColorRect"
@onready var tab_bar = $"TabBar" as TabContainer

var next_profile = 1

func _ready():
	get_tree().paused = true
	
	for profile in tab_bar.get_children():
		add_mods_profile(profile)


func add_mods_profile(profile):
	for mod in Gmm.mods:
		if not profile is HBoxContainer: continue
		var scroll_container = profile.get_child(0)
		var vbox_container = scroll_container.get_child(0)
		
		var mod_entry = mod_entry_scene.instantiate()
		mod_entry.get_node("Name").text = Gmm.mods[mod].manifest.name if Gmm.mods[mod].manifest.has("name") else "No Name"
		mod_entry.get_node("Description").text = Gmm.mods[mod].manifest.description if Gmm.mods[mod].manifest.has("description") else "No Description"
		mod_entry.get_node("Version").text = Gmm.mods[mod].manifest.version if Gmm.mods[mod].manifest.has("version") else "No Version"
		if Gmm.mods[mod].has("icon"): 
			mod_entry.get_node("TextureRect").texture = Gmm.mods[mod].icon
		
		vbox_container.add_child(mod_entry)


func _on_continue_button_pressed():
	visible = false
	get_tree().paused = false
	Gmm.reload_mods()


func _on_tab_bar_tab_selected(tab):
	if tab == tab_bar.get_tab_count() - 1:
		var new_tab = profile_container.instantiate()
		new_tab.name = "Profile %d" % [next_profile]
		next_profile += 1
		add_mods_profile(new_tab)
		tab_bar.add_child(new_tab)
		tab_bar.move_child(tab_bar.get_child(tab), tab_bar.get_tab_count() - 1)
		tab_bar.current_tab = tab
	pass
