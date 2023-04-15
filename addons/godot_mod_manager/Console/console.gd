extends CanvasLayer

@onready var inputBox = $"Input"
@onready var outputBox = $"Output"
@onready var commandHistory = $"CommandHistory"
@onready var panel = $"Panel"

const DEFAULT_INPUT_BOX_HEIGHT = 50
const DEFAULT_INPUT_BOX_MARGIN = 20
const DEFAULT_OUTPUT_BOX_MARGIN = 20

var clearScreen = true
var devMode = false
var input_template = "[color=gold]> %s[/color]"

var commandhistoryline = null
var beginningElement = false

var input_box_height = DEFAULT_INPUT_BOX_HEIGHT
var input_box_margin = DEFAULT_INPUT_BOX_MARGIN
var output_box_margin = DEFAULT_OUTPUT_BOX_MARGIN

var devmode = false

func _ready():
	get_tree().get_root().connect("size_changed", set_size)
	set_size()

func set_size():
	var screen_size = get_viewport().get_visible_rect().size
	panel.size = screen_size
	outputBox.size = Vector2(screen_size.x - output_box_margin*2, screen_size.y - input_box_height - input_box_margin * 2 - output_box_margin*2)
	outputBox.position = Vector2(output_box_margin, output_box_margin)
	inputBox.size = Vector2(screen_size.x - input_box_margin*2, input_box_height)
	inputBox.position = Vector2(input_box_margin, screen_size.y - input_box_height - input_box_margin)

func setVisible():
	beginningElement = false
	commandhistoryline = null
	inputBox.grab_focus()
	self.visible = true
	get_tree().paused = true


func setInvisible():
	if (clearScreen): outputBox.text = ""
	inputBox.text = ""
	self.visible = false
	get_tree().paused = false


func toggleVisibility():
	if self.visible:
		setInvisible()
	else:
		setVisible()


func setHistoryMax(max):
	commandHistory.max_history = max


func clearHistory():
	commandHistory.history = LinkedList.new()


func _input(event):
	if event is InputEventKey and event.is_pressed() and Gmm.selection.visible == false:
		if InputMap.has_action("console") and event.is_action("console"):
			toggleVisibility()
			get_viewport().set_input_as_handled()
		
		elif self.visible:
			if event.keycode == KEY_UP:
				goto_command_history(-1)
			if event.keycode == KEY_DOWN:
				goto_command_history(1)


func goto_command_history(offset):
	if commandHistory.history.size() == 0:
		inputBox.text = ""
		inputBox.call_deferred("set_caret_column", 9999999)
		return
	
	if(offset == -1):
		if(commandhistoryline == null):
			if(beginningElement):
				return
			else:
				commandhistoryline = commandHistory.history.getLast()
				inputBox.text = commandhistoryline.data
				inputBox.call_deferred("set_caret_column", 9999999)
				return
		elif(commandhistoryline.prev == null):
			commandhistoryline = null
			beginningElement = true
			inputBox.text = ""
			return
		
		commandhistoryline = commandhistoryline.prev
	if(offset == 1):
		if(commandhistoryline == null):
			if(not beginningElement):
				return
			else:
				commandhistoryline = commandHistory.history.getFirst()
				inputBox.text = commandhistoryline.data
				inputBox.call_deferred("set_caret_column", 9999999)
				return
		elif(commandhistoryline.next == null):
			commandhistoryline = null
			beginningElement = false
			inputBox.text = ""
			return
		
		commandhistoryline = commandhistoryline.next
	
	inputBox.text = commandhistoryline.data
	inputBox.call_deferred("set_caret_column", 9999999)

	
func process_command(text: String):
	outputText(input_template % [text])
	
	var words = text.split(" ", false)
	words = Array(words)
	
	if (words.size() == 0):
		return
	
	var commandWord = words.pop_front()
	
	commandHistory.addHistory(text)
	
	for command in Gmm.commands.values():
		if command.name == commandWord or command.alias == commandWord:
			if devmode and command.devmode or !devmode and command.usermode or !command.devmode and !command.usermode:
				var quoted = false
				var quoted_word = ""
				var new_words = []
				for i in range(0, words.size()):
					var done = false
					if words[i].begins_with("\"") and not quoted:
						quoted = true
						quoted_word = words[i].substr(1)
						done = true
					if quoted and not done:
						quoted_word += " " + words[i]
					if words[i].ends_with("\"") and quoted:
						quoted = false
						quoted_word = quoted_word.substr(0, quoted_word.length() - 1)
						new_words.append(quoted_word)
						done = true
					
					if not quoted and not done:
						new_words.append(words[i])
				words = new_words
				
				if command.args.size() >= words.size() and command.args.size() - command.default_args <= words.size():
					for i in range(0, words.size()):
						if command.args[i].type == TYPE_INT:
							if not words[i].is_valid_int():
								outputText("[color=red]ERROR:[/color] An integer argument was not provided an integer")
								return;
							else:
								words[i] = int(words[i])
					outputText(command.file.callv(command.method_name, words))
				else:
					outputText("[color=red]ERROR:[/color] Invalid amount of arguments. Expected %d to %d" % [command.args.size() - command.default_args, command.args.size()])
				return
	
	outputText("Invalid Command")


func checkType(string, type):
	if type == "integer":
		return string.is_valid_int()
	if type == "float":
		return string.is_valid_float()
	if type == "string":
		return true
	if type == "boolean":
		return (string == "true" or string == "false")
	return false


func outputText(text: String):
	if(text != ""):
		if outputBox.text != "":
			outputBox.text = str(outputBox.text, "\n", text)
		else:
			outputBox.text = str(outputBox.text, text)


func _on_input_text_submitted(new_text: String):
	inputBox.clear()
	process_command(new_text)
	beginningElement = false
	commandhistoryline = null
