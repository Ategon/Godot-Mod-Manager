extends CanvasLayer

@onready var inputBox = $"Input"
@onready var outputBox = $"Output"
@onready var commandHistory = $"CommandHistory"
@onready var panel = $"Panel"

var clearScreen = true
var devMode = false

var commandhistoryline = null
var beginningElement = false

const INPUT_BOX_HEIGHT = 50
const INPUT_BOX_MARGIN = 5
const OUTPUT_BOX_MARGIN = 5

func _ready():
	get_tree().get_root().connect("size_changed", set_size)
	set_size()

func set_size():
	var screen_size = get_viewport().get_visible_rect().size
	panel.size = screen_size
	outputBox.size = Vector2(screen_size.x - OUTPUT_BOX_MARGIN*2, screen_size.y - INPUT_BOX_HEIGHT - OUTPUT_BOX_MARGIN*2)
	outputBox.position = Vector2(OUTPUT_BOX_MARGIN, OUTPUT_BOX_MARGIN)
	inputBox.size = Vector2(screen_size.x - INPUT_BOX_MARGIN*2, INPUT_BOX_HEIGHT - INPUT_BOX_MARGIN*2)
	inputBox.position = Vector2(INPUT_BOX_MARGIN, screen_size.y - INPUT_BOX_HEIGHT)

func setVisible():
	beginningElement = false
	commandhistoryline = null
	inputBox.grab_focus()
	self.visible = true
	get_tree().paused = true


func setInvisible():
	if (clearScreen): outputBox.text = "Debug Console"
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


func _input(event):
	if event is InputEventKey and event.is_pressed():
		if InputMap.has_action("console") and event.is_action("console"):
			toggleVisibility()
		
		if self.visible:
			if event.keycode == KEY_UP:
				goto_command_history(-1)
			if event.keycode == KEY_DOWN:
				goto_command_history(1)


func goto_command_history(offset):
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


#var builtIns = {
#  "help": help(),
#  "devmode": devmode(),
#  "usermode": usermode()
#}

var devmode = false

	
func process_command(text: String):
	outputText("[color=gold]> %s[/color]" % [text])
	
	var words = text.split(" ", false)
	words = Array(words)
	
	if (words.size() == 0):
		return
	
	var commandWord = words.pop_front()
	
	commandHistory.addHistory(text)
	
	#todo make it not static
	
	var commands = load("res://addons/godot_mod_manager/commands.gd").new() # TODO Change to accomodate mods
	
	var methods = commands.get_method_list()
	
	if(commands.has_method(commandWord) and not (commandWord.begins_with("d_") or commandWord.begins_with("u_") or commandWord.begins_with("h_"))):
		for method in methods:
			if method.name == commandWord:
				if method.args.size() == words.size():
					outputText(commands.callv(commandWord, words))
				else:
					outputText("Invalid amount of arguments. Expected %d" % [method.args.size()])
	else:
		if(devmode and commands.has_method("d_" + commandWord)):
			for method in methods:
				if method.name == "d_" + commandWord:
					if method.args.size() == words.size():
						outputText(commands.callv("d_" + commandWord, words))
					else:
						outputText("Invalid amount of arguments. Expected %d" % [method.args.size()])
		elif(not devmode and commands.has_method("u_" + commandWord)):
			for method in methods:
				if method.name == "u_" + commandWord:
					if method.args.size() == words.size():
						outputText(commands.callv("u_" + commandWord, words))
					else:
						outputText("Invalid amount of arguments. Expected %d" % [method.args.size()])
		else: 
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
		outputBox.text = str(outputBox.text, "\n", text)


func _on_input_text_submitted(new_text: String):
	inputBox.clear()
	process_command(new_text)
	beginningElement = false
	commandhistoryline = null
