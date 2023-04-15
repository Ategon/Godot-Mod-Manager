extends CanvasLayer

@onready var profile_container = preload("res://addons/godot_mod_manager/Selection/profile_container.tscn")
@onready var mod_entry_scene = preload("res://addons/godot_mod_manager/Selection/mod_entry.tscn")

@onready var color_rect = $"ColorRect"
@onready var tab_bar = $"TabBar" as TabContainer
@onready var name_popup = $"NamePopup" as Control
@onready var name_text = $"NamePopup/MarginContainer/VBoxContainer/TextEdit" as TextEdit
@onready var name_button = $"NamePopup/MarginContainer/VBoxContainer/Button" as Button

var next_profile = 1

var profiles = []
var selected_profile = 0

func save_profiles():
	var file = FileAccess.open("user://mod_profiles.dat", FileAccess.WRITE)
	file.store_line(JSON.stringify(profiles, "\t"))
	file.close()


func load_profiles():
	var file = FileAccess.open("user://mod_profiles.dat", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		print(content)
		file.close()
		return JSON.parse_string(content)
	else:
		return [{"name": "Profile 1"}]

func _init():
	profiles = load_profiles()

func _ready():
	get_tree().paused = true
	
	for object in profiles:
		_create_tab(object)
	
	tab_bar.current_tab = 0


func add_mods_profile(profile, object):
	for mod in Gmm.mods:
		if not profile is HBoxContainer: continue
		var scroll_container = profile.get_child(0)
		var vbox_container = scroll_container.get_child(0)
		
		var mod_entry = mod_entry_scene.instantiate()
		mod_entry.get_node("Name").text = Gmm.mods[mod].manifest.name if Gmm.mods[mod].manifest.has("name") else "No Name"
		mod_entry.get_node("Description").text = Gmm.mods[mod].manifest.description if Gmm.mods[mod].manifest.has("description") else "No Description"
		mod_entry.get_node("Version").text = Gmm.mods[mod].manifest.version if Gmm.mods[mod].manifest.has("version") else "No Version"
		
		if (object.has("mods") && object.mods.has(Gmm.mods[mod].manifest.name)):
			print("aaa")
			mod_entry.get_node("CheckButton").button_pressed = true
		if Gmm.mods[mod].has("icon"): 
			mod_entry.get_node("TextureRect").texture = Gmm.mods[mod].icon
		
		vbox_container.add_child(mod_entry)


func _on_continue_button_pressed():
	save_profiles()
	visible = false
	get_tree().paused = false
	Gmm.reload_mods()


func _on_tab_bar_tab_selected(tab):
	if tab == tab_bar.get_tab_count() - 1:
		_add_profile()
	selected_profile = tab
	pass

func _add_profile():
	var profile = {
		"name": "New Profile"
	}
	profiles.push_back(profile)
	_create_tab(profile)
	tab_bar.current_tab = tab_bar.get_tab_count() - 2

func _create_tab(object):
	var new_tab = profile_container.instantiate()
	new_tab.name = object.name
	add_mods_profile(new_tab, object)
	tab_bar.add_child(new_tab)
	tab_bar.move_child(tab_bar.get_child(tab_bar.get_tab_count() - 2), tab_bar.get_tab_count() - 1)

func delete_selected_profile():
	profiles.remove_at(tab_bar.current_tab)
	tab_bar.remove_child(tab_bar.get_current_tab_control())
	if tab_bar.current_tab > 0:
		tab_bar.current_tab = tab_bar.current_tab - 1

var new_name

func rename_selected_profile():
	name_popup.visible = true
	name_text.text = tab_bar.get_current_tab_control().name
	new_name = name_text.text

func _on_button_pressed():
	profiles[tab_bar.current_tab].name = new_name
	tab_bar.get_current_tab_control().name = new_name
	name_popup.visible = false


func _on_text_edit_text_changed():
	new_name = name_text.text
	if new_name == "" and not name_button.disabled:
		name_button.disabled = true
	elif new_name != "" and name_button.disabled:
		name_button.disabled = false


func enable_mod(name):
	if profiles[tab_bar.current_tab].has("mods"):
		if profiles[tab_bar.current_tab]["mods"].has(name):
			pass
		else:
			profiles[tab_bar.current_tab]["mods"].push_back(name)
	else:
		profiles[tab_bar.current_tab]["mods"] = [name]

func disable_mod(name):
	if profiles[tab_bar.current_tab].has("mods"):
		if profiles[tab_bar.current_tab]["mods"].has(name):
			profiles[tab_bar.current_tab]["mods"].remove_at(profiles[tab_bar.current_tab]["mods"].find(name))
		else:
			pass
	else:
		pass
