extends Node
# Main GMM file to handle loading and storing mod data

var data = {}

var FileFunctions = {
	"changelog.txt": _readChangelog,
	"commands.gd": _readCommands,
	"*.gd": _readScriptResource,
	"*.txt": _readTxt,
	"*.png.import": _readPngImport,
	"*.png": _readPng,
}


## Built In Methods ##

func _ready():
	reload_mods()


## Public Methods ##

# Delete cached mod data and then read in data from the project's parts folder
# and the user's mods folder and set the mod data to that.
func reload_mods() -> void:
	data = {} # Remove all old mod data
	
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
			data = _mergeObjects(project_mods_data[mod_data], data)
	
	# Open mod folder on player machine (Create if none)
	var user_dir = DirAccess.open("user://")
	if not user_dir.dir_exists("mods"):
		user_dir.make_dir("mods")
	var mods_data = _readDirectory("user://mods")
	
	# Merge all mods into the mod data. TODO: Change to handle dependencies
	for mod_data in mods_data:
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


func _readChangelog(path):
	var entry = {"key": "Changelog"}
	var data = _getNewlineFile(path)
	
	var i = -1
	var splitData = []
	for line in data:
		if(line.begins_with("---")):
			i += 1
			splitData.push_back([])
		else:
			splitData[i].push_back(line)
	
	for dataLine in splitData:  
		var localEntry = _readEntry(dataLine)
		if(!localEntry.has("Version")): continue
		entry[localEntry.Version] = localEntry
	return entry
	
## Given an unparsed input entry of an array of strings, convert it to an object
## using the parsing algorithm
func _readEntry(input: PackedStringArray):
	var entry = {}
	var indentationLevels: PackedStringArray = []
	var currentIndentation: int = 0
	
	for line in input:
		var splitLine: PackedStringArray = line.strip_edges().split(":")
		var actualIndentation: int = _countIndentation(line)
		
		if (actualIndentation < currentIndentation):
			currentIndentation = actualIndentation
			indentationLevels = indentationLevels.slice(0, currentIndentation)
		elif (currentIndentation < actualIndentation):
			# throw error
			pass
		
		match splitLine.size():
			1:
				if(splitLine[0].ends_with("[]")):
					
					var i = 0
					var position = entry
					while(i < actualIndentation - 1):
						if(position and position.has(indentationLevels[i])):
							position = position.get(indentationLevels[i])
							i += 1
						else:
							#error
							break
					
					if(indentationLevels.size() > 0 and !position.has(indentationLevels[i])):
						position[indentationLevels[i]] = {}
					
					
					var lineName = splitLine[0].substr(0, splitLine[0].length() - 2)
					indentationLevels.push_back(lineName)
					currentIndentation += 1
				elif(splitLine[0].begins_with("-")):
					var i = 0
					var position = entry

					while(i < actualIndentation - 1):
						position = position.get(indentationLevels[i])
						i += 1
					
					if(!position.has(indentationLevels[i])):
						position[indentationLevels[i]] = []
					position = position.get(indentationLevels[i])
					
					position.push_back(splitLine[0].substr(2))
				else:
					var i = 0
					var position = entry

					while(i < actualIndentation - 1):
						position = position.get(indentationLevels[i])
						i += 1
					
					if(!position.has(indentationLevels[i])):
						position[indentationLevels[i]] = []
					i += 1
					position = position.get(indentationLevels[i])
					
					position.Values.push_back(splitLine[0])
			2:
				var i = 0
				var position = entry
				
				while(i < actualIndentation - 1):
					position = position.get(indentationLevels[i])
					i += 1
				
				if(indentationLevels.size() > 0):
					if(!position.has(indentationLevels[i])):
						position[indentationLevels[i]] = {}
					i += 1
					position = position.get(indentationLevels[i])
				
				position[splitLine[0]] = splitLine[1].strip_edges()
			_:
				# throw error
				pass
	return entry

## Read the contents of a file provided a path and then return the contents as
## an array of strings delimited by newlines
func _getNewlineFile(path: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	return content.split("\n", false)


func _readCommands(path):
	var localData = { "key": "commands" }
	
	localData["File"] = load(path)
	
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
