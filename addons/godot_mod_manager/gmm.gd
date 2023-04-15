extends Node
# Main GMM file to handle loading and storing mod data

var data = {}
var mods = {}
var commands = {}

@onready var console = $"Console"
@onready var selection = $"Selection"

var FileFunctions = {
	"commands.gd": _readCommands,
	"*.gd": _readScriptResource,
	"*.txt": _readTxt,
	"*.png.import": _readPngImport,
	"*.png": _readPng,
}

var CoreModFunctions = {
	"icon.png": _readIcon,
	"manifest.json": _readManifest,
	"README.md": _readReadme,
}


## Built In Methods ##

func _init():
	get_mods()


## Public Methods ##


func get_mods() -> void:
	commands = _readCommands("res://addons/godot_mod_manager/commands.gd")
	mods = {}
	
	var res_dir = DirAccess.open("res://")
	if res_dir.dir_exists("mods"):
		var mods_dir = DirAccess.open("res://mods")
		for mod in mods_dir.get_directories():
			var mod_dir = DirAccess.open("res://mods/" + mod)
			var mod_data = {}
			for core_mod_function in CoreModFunctions:
				if mod_dir.file_exists(core_mod_function):
					var new_entry = CoreModFunctions[core_mod_function].call("%s" % ["res://mods/" + mod + "/" + core_mod_function])
					mod_data[new_entry.keys()[0]] = new_entry.values()[0]
			if mod_data.has("manifest"):
				if mod_data.manifest.has("name"):
					if mods.has(mod_data.manifest.name):
						push_warning("Attempted to add a second mod with name %s" % [mod_data.name])
						continue
					mods[mod_data.manifest.name] = mod_data

# Delete cached mod data and then read in data from the project's parts folder
# and the user's mods folder and set the mod data to that.
func reload_mods() -> void:
	data = {} # Remove all old mod data
	
	if selection == null:
		selection = get_node("Selection")
	
	var selected_profile = selection.profiles[selection.selected_profile]
	
	# Open part folder from project (Ignore if none) and if exists set mod data to it
	var res_dir = DirAccess.open("res://")
	if res_dir.dir_exists("parts"):
		data = _readDirectory("res://parts")
	
	# Open mod folder from project (Ignore if none). Optional folder to possibly be used
	# for mod building
	if res_dir.dir_exists("mods"):
		var project_mods_data = _readDirectory("res://mods")
		
		# Merge all project mods into the mod data. TODO: Change to handle dependencies
		for mod_data in project_mods_data:
			if not selected_profile.has("mods") or not selected_profile.mods.any(func(x): x == mod_data): continue
			data = _mergeObjects(project_mods_data[mod_data], data)
	
	# Open mod folder on player machine (Create if none)
	var user_dir = DirAccess.open("user://")
	if not user_dir.dir_exists("mods"):
		user_dir.make_dir("mods")
	var mods_data = _readDirectory("user://mods")
	
	# Merge all mods into the mod data. TODO: Change to handle dependencies
	for mod_data in mods_data:
		if not selected_profile.has("mods") or not selected_profile.mods.any(func(x): x == mod_data): continue
		data = _mergeObjects(mods_data[mod_data], data)
	
	# Reload all nodes that have a reload function
	var nodes = GetAllTreeNodes()
	for node in nodes:
		if node.has_method("_reload"):
			node.callv("_reload", [])


# Iterate over every node in the tree recursively (using DFS) and return the result.
func GetAllTreeNodes(node: Node = get_tree().root, listOfAllNodesInTree: Array[Node] = []) -> Array[Node]:
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree


## Private Methods ##


func _getFileHandling(file):
	var splitFile = file.split(".", true, 1)
	
	for fileFunction in FileFunctions:
		if(fileFunction == file):
			return FileFunctions[fileFunction]
		
		var splitFileFunction = fileFunction.split(".", true, 1)
		
		if(splitFileFunction[0] == "*" and splitFileFunction[1] == splitFile[1]):
			return FileFunctions[fileFunction]
	
	return null


func _readScriptResource(path):
	return load(path)


func _readPngImport(path):
	return path.rsplit(".", true, 1)[0]


func _readPng(path):  
	return load(path)


func _readIcon(path):
	return {"icon": load(path)}


func _readManifest(path):
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var contents = JSON.parse_string(file.get_as_text())
	file.close()
	return {"manifest": contents}


func _readReadme(path):
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var contents = file.get_as_text()
	file.close()
	return {"readme": contents}


func _readCommands(path):
	var localData = { }
	
	var file = load(path).new()
	var command_list = file.get_script().get_script_method_list()
	
	for method in command_list:
		if method.name:
			var args: Array = method.args
			var i = 0
			var name = method.name
			var help = ""
			var devmode = false
			var usermode = false
			var alias = ""
			var default_arg_amount = 0
			var act_default_arg = 0
			var category = "Uncategorized"
			
			if name.begins_with("h_"):
				continue
			elif name.begins_with("d_"):
				devmode = true
				name = name.substr(2)
			elif name.begins_with("u_"):
				usermode = true
				name = name.substr(2)
			
			var non_default_args = args.size() - method.default_args.size()
			
			while i < args.size():
				if i >= non_default_args:
					default_arg_amount += 1
					act_default_arg += 1
					
					if args[i].name == "help" or args[i].name == "alias" or args[i].name == "category":
						act_default_arg -= 1
						if args[i].name == "help":
							help = method.default_args[default_arg_amount-1]
						if args[i].name == "alias":
							alias = method.default_args[default_arg_amount-1]
						if args[i].name == "category":
							category = method.default_args[default_arg_amount-1]
						args.remove_at(i)
						i -= 1
				i += 1
			
			localData[name] = {
				"name": name,
				"method_name": method.name,
				"args": args,
				"help": help,
				"alias": alias,
				"file": file,
				"devmode": devmode,
				"usermode": usermode,
				"default_args": act_default_arg,
				"category": category
			}
	
	return localData
	
func _mergeObjects(object1, object2):
	var newObject = {}
	for key in object1:
		newObject[key] = object1[key]
	for key in object2:
		if(newObject.has(key)):
			if(typeof(newObject[key]) == TYPE_STRING):
				newObject[key] = object1[key]
			elif(typeof(newObject[key]) == TYPE_OBJECT):
				if newObject[key] is Texture:
					newObject[key] = object1[key]
				else:
					newObject[key] = _mergeObjects(object1[key], object2[key])
			elif(typeof(newObject[key]) == TYPE_DICTIONARY):
				newObject[key] = _mergeObjects(object1[key], object2[key])
			elif(typeof(newObject[key]) == TYPE_ARRAY):
				newObject[key] = object1[key] + object2[key]
		else:
			newObject[key] = object2[key]
	return newObject

func _readDirectory(path):
	var dir = DirAccess.open(path)
	var localData = {}
	
	if not dir:
		print("An error occurred when trying to access the path.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			var microData = _readDirectory("%s/%s" % [path, file_name])
			if microData:
				localData[file_name] = microData
		else:
			var fileHandling = _getFileHandling(file_name)
			
			if (fileHandling):
				var microData = fileHandling.call("%s/%s" % [path, file_name])
				if microData:
					localData[file_name.split(".")[0]] = microData  
		
		file_name = dir.get_next()
	
	return localData


func _countIndentation(string: String):
	var tabs = 0
	
	for character in string:
		if(character == "\t"):
			tabs += 1
		else:
			return tabs
	
	return tabs


func _readTxt(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var localData = {}
	
	var splitContent = content.split("\n", false)
	
	var indentation = 0
	var indentationLevels = []
	
	for contentPiece in splitContent:
		var actualIndentation = _countIndentation(contentPiece)
		while(actualIndentation < indentation):
			indentation -= 1
			indentationLevels.pop_back()
		if(contentPiece.ends_with("[]")):
			var microData = localData
			var i = 0
			while i < indentation:
				microData = microData[indentationLevels[i]]
				i += 1
			
			indentation += 1
			indentationLevels.append(contentPiece.trim_suffix("[]"))
			microData[contentPiece.trim_suffix("[]")] = {}
		else:
			var splitArgs = contentPiece.split(":")
			if(splitArgs.size() == 2):
				var microData = localData
				var i = 0
				while i < indentation:
					microData = microData[indentationLevels[i]]
					i += 1
				microData[splitArgs[0].strip_edges()] = splitArgs[1].strip_edges()
			elif splitArgs.size() == 1:
				var microData = localData
				var i = 0
				while i < indentation - 1:
					microData = microData[indentationLevels[i]]
					i += 1
				if indentationLevels.size() == 0: continue
				if typeof(microData[indentationLevels[indentationLevels.size()-1]]) == TYPE_DICTIONARY:
					if microData[indentationLevels[indentationLevels.size()-1]].keys().size() == 0:
						microData[indentationLevels[indentationLevels.size()-1]] = [splitArgs[0].strip_edges()]
				else:
					microData[indentationLevels[indentationLevels.size()-1]] += [splitArgs[0].strip_edges()]
				
	return localData
