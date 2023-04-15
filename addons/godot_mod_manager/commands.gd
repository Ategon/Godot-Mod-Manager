extends Resource


func ping(help = "Prints out Pong to the console", category = "Util"):
	return "Pong!"


func echo(text: String, help = "Prints out the given text to the console", category = "Util"):
	return text


func clear(help = "Clears the console", alias = "cls", category = "Util"):
	Gmm.console.outputBox.text = ""
	return ""


func reload(help = "Reloads mod data", alias = "r", category = "Mods"):
	Gmm.reload_mods()
	return "Reloaded mods"


func command_history_max(max: int, category = "Console"):
	Gmm.console.setHistoryMax(max)
	return "Successfully set history max to %s" % [max]


func clear_history(category = "Console"):
	Gmm.console.clearHistory()
	return "Cleared the command history"


func set_input_template(template: String = "", alias = "sit", category = "Console"):
	if template == "":
		Gmm.console.input_template = "[color=gold]> %s[/color]"
		return "Set template to the default"
	else:
		Gmm.console.input_template = template
		return "Edited template"


func set_input_box_height(height: int = -1, alias = "sibh", category = "Console"):
	if height == -1:
		Gmm.console.input_box_height = Gmm.console.DEFAULT_INPUT_BOX_HEIGHT
		Gmm.console.set_size()
		return "Set height of the input box to the default"
	else:
		Gmm.console.input_box_height = height
		Gmm.console.set_size()
		return "Set height of the input box to %d" % [height]


func set_input_box_margin(margin: int = -1, alias = "sibm", category = "Console"):
	if margin == -1:
		Gmm.console.input_box_margin = Gmm.console.DEFAULT_INPUT_BOX_MARGIN
		Gmm.console.set_size()
		return "Set height of the input box to the default"
	else:
		Gmm.console.input_box_margin = margin
		Gmm.console.set_size()
		return "Set margin of the input box to %d" % [margin]


func set_output_box_margin(margin: int = -1, alias = "sobm", category = "Console"):
	if margin == -1:
		Gmm.console.output_box_margin = Gmm.console.DEFAULT_OUTPUT_BOX_MARGIN
		Gmm.console.set_size()
		return "Set height of the input box to the default"
	else:
		Gmm.console.output_box_margin = margin
		Gmm.console.set_size()
		return "Set margin of the output box to %d" % [margin]


func console_exit_clear(state = null, help = "Sets whether to make the console clear all text when you exit it", alias = "cec", category = "Console"):
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


func help(command: String = "", help = "Shows all available commands or information about a given command", category = "Util"):
	if command == "": # Command list
		var dict = {}
		
		for name in Gmm.commands.keys():
			if Gmm.console.devmode and Gmm.commands[name].devmode or !Gmm.console.devmode and Gmm.commands[name].usermode or !Gmm.commands[name].devmode and !Gmm.commands[name].usermode:
				var string = name
				if Gmm.console.devmode and Gmm.commands[name].devmode or !Gmm.console.devmode and Gmm.commands[name].usermode:
					string = "[color=d1d1d1]%s[/color]" % [string]
				
				if dict.has(Gmm.commands[name].category):
					dict[Gmm.commands[name].category] += ", " + string 
				else:
					dict[Gmm.commands[name].category] = string
		
		
		var string = ""
		for section in dict:
			string += "[color=a1a1a1]- - %s - -[/color]\n%s\n" % [section, dict[section]]
		if string != "":
			string = string.substr(0, string.length() - 1) 
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

func u_devmode(help = "Get access to commands meant for development", category = "Util"):
	Gmm.console.devmode = true
	return "Set Dev Mode"


func d_usermode(help = "Set your access to only being able to run regular commands", category = "Util"):
	Gmm.console.devmode = false
	return "Removed Dev Mode"


func d_edit_data(path: String, value: String, category = "Data"):
	var currentpos = Gmm.data
	var split_path = path.split("/")
	var last_word = split_path[-1]
	split_path.remove_at(split_path.size() - 1)
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


func d_add_data(path: String, value: String, category = "Data"):
	var currentpos = Gmm.data
	var split_path = path.split("/")
	var last_word = split_path[-1]
	split_path.remove_at(split_path.size() - 1)
	for word in split_path:
		if currentpos.has(word):
			currentpos = currentpos[word]
		else:
			return "[color=red]ERROR:[/color] %s is not a valid directory" % [word]
	
	if currentpos.has(last_word):
		return "%s already exists" % [last_word]
	else:
		currentpos[last_word] = value
	return "Set value of %s to %s" % [last_word, value]


func d_remove_data(path: String, category = "Data"):
	var currentpos = Gmm.data
	var split_path = path.split("/")
	var last_word = split_path[-1]
	split_path.remove_at(split_path.size() - 1)
	for word in split_path:
		if currentpos.has(word):
			currentpos = currentpos[word]
		else:
			return "[color=red]ERROR:[/color] %s is not a valid directory" % [word]
	
	if currentpos.has(last_word):
		currentpos.erase(last_word)
	else:
		return "%s is not a valid attribute" % [last_word]
	return "Removed %s" % [last_word]

func show_mod_window(category = "Mods"):
	Gmm.selection.show_mod_selection()
	return "Showing mod selection window"

func enable_mod(name: String, category = "Mods"):
	var status = Gmm.selection.select_mod(name)
	if status:
		Gmm.reload_mods()
		return "Enabled %s and reloaded mods" % [name]
	else:
		return "[color=red]ERROR:[/color] %s is not a valid mod name" % [name]

func disable_mod(name: String, category = "Mods"):
	var status = Gmm.selection.deselect_mods(name)
	if status:
		Gmm.reload_mods()
		return "Disabled %s and reloaded mods" % [name]
	else:
		return "[color=red]ERROR:[/color] %s is not a valid mod name" % [name]

func profile(help = "Show the name of the currently selected profile", category = "Mods"):
	return Gmm.selection.tab_bar.get_current_tab_control().name

func mods(help = "Show a list of all currently enabled mods in the selected profile", category = "Mods"):
	var profile = Gmm.selection.profiles[Gmm.selection.selected_profile]
	if profile.has("mods"):
		if profile.mods.size() != 0:
			return profile.mods.reduce(
				func(accum, mod):
					if accum == null:
						return mod
					else:
						return accum + ", " + mod
			)
		else:
			return "No Mods"
	else:
		return "No Mods"
