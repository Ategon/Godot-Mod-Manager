extends Resource


func ping(help = "Prints out Pong to the console", category = "Util"):
	return "Pong!"


func echo(text: String, help = "Prints out the given text to the console", category = "Util"):
	return text


func clear(help = "Clears the console", alias = "cls", category = "Util"):
	Gmm.console.outputBox.text = ""
	return ""


func reload(help = "Reloads mod data", alias = "r", category = "Util"):
	Gmm.reload_mods()
	return "Reloaded mods"


func command_history_max(max: int, category = "Console"):
	Gmm.console.setHistoryMax(max)
	return "Successfully set history max to %s" % [max]


func clear_history():
	Gmm.console.clearHistory()
	return "Cleared the command history"


func set_input_template(template: String = "", alias = "sit"):
	if template == "":
		Gmm.console.input_template = "[color=gold]> %s[/color]"
		return "Set template to the default"
	else:
		Gmm.console.input_template = template
		return "Edited template"


func set_input_box_height(height: int = -1, alias = "sibh"):
	if height == -1:
		Gmm.console.INPUT_BOX_HEIGHT = 50
		Gmm.console.set_size()
		return "Set height of the input box to the default"
	else:
		Gmm.console.INPUT_BOX_HEIGHT = height
		Gmm.console.set_size()
		return "Set height of the input box to %d" % [height]


func console_exit_clear(state = null, help = "Sets whether to make the console clear all text when you exit it", alias = "cec"):
	if state == null:
		state = !Gmm.console.clearScreen
	else:
		if state == "true":
			state = true
		elif state == "false":
			state = false
		else:
			return "Invalid state provided"
	
	Gmm.console.clearScreen = state
	return "The console will now %s when it closes" % ["clear text" if state else "keep text"]


func help(command: String = "", help = "Shows all available commands or information about a given command"):
	if command == "": # Command list
		var string = ""
		for name in Gmm.commands.keys():
			if Gmm.console.devmode and Gmm.commands[name].devmode or !Gmm.console.devmode and Gmm.commands[name].usermode or !Gmm.commands[name].devmode and !Gmm.commands[name].usermode:
				string += name + ", "
		if string != "":
			string = string.substr(0, string.length() - 2)
		return string
	else: # Info about command
		if Gmm.commands.has(command):
			if Gmm.console.devmode and Gmm.commands[command].devmode or !Gmm.console.devmode and Gmm.commands[command].usermode or !Gmm.commands[command].devmode and !Gmm.commands[command].usermode:
				var args = ""
				var arg_amount = 0
				for arg in Gmm.commands[command].args:
					var string = "%s: %s" % [arg.name, h_get_type(arg.type)]
					if arg_amount < Gmm.commands[command].args.size() - Gmm.commands[command].default_args:
						args += "<%s>" % [string]
					else:
						args += "[%s]" % [string]
					arg_amount += 1
				print(args)
				
				return "%s%s\n%s%s" % [Gmm.commands[command].name, " %s" % [args] if args != "" else "", Gmm.commands[command].help, "\nAlias: %s" % [Gmm.commands[command].alias] if Gmm.commands[command].alias != "" else ""]
			else:
				return "Invalid command"
		else:
			return "Invalid command"

func h_get_type(thing):
	match (thing):
		TYPE_STRING:
			return "String"
		TYPE_INT:
			return "Int"
		_:
			return "Unknown"

func u_devmode(help = "Get access to commands meant for development"):
	Gmm.console.devmode = true
	return "Set Dev Mode"


func d_usermode(help = "Set your access to only being able to run regular commands"):
	Gmm.console.devmode = false
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
