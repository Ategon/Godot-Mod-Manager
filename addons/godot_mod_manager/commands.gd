extends Resource


func ping(help = "Prints out Pong to the console"):
	return "Pong!"


func echo(text: String, help = "Prints out the given text to the console"):
	return text


func clear(help = "Clears the console", alias = "cls"):
	Gmm.Console.outputBox.text = ""
	return ""


func reload(help = "Reloads mod data", alias = ["r", "rel"]):
	Gmm.reload_mods()
	return "Reloaded mods"


func command_history_max(max: int):
	Gmm.Console.setHistoryMax(max)
	return "Successfully set history max to %s" % [max]


func clear_history():
	Gmm.Console.clearHistory()
	return "Cleared the command history"


func help(command: String = "", help = "Shows all available commands or information about a given command"):
	if command == "": # Command list
		return ""
	else: # Info about command
		return ""


func u_devmode(help = "Get access to commands meant for development"):
	Gmm.Console.devmode = true
	return "Set Dev Mode"


func d_usermode(help = "Set your access to only being able to run regular commands"):
	Gmm.Console.devmode = false
	return "Removed Dev Mode"


func d_editdata(path: String, value: String):
	var currentpos = Gmm.Data
	var split_path = path.split("/")
	var last_word = split_path[-1]
	split_path.remove_at(2)
	
	for word in split_path:
		if currentpos.has(word):
			currentpos = currentpos[word]
		else:
			return "[color=red]ERROR:[/color] %s is not a valid directory" % [word]
	
	if currentpos.has(last_word):
		currentpos[last_word] = value
	else:
		return "%s is not a valid attribute" % [last_word]
	return "Set value of %s to %s" % [last_word, value]


func d_adddata(path: String, value: String):
	pass


func d_removedata(path: String):
	pass
