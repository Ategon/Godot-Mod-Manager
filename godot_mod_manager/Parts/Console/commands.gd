func command_history_max(max):
  Console.setHistoryMax(max.to_int())
  return "Successfully set history max to %s" % [max]
  
func clear():
  Console.outputBox.text = "Debug Console"
  return ""

func help():
  var string = ""
  var commands = Data.Data.commands.File.new()
  var commandScript = commands.script.get_script_method_list()
  for command in commandScript:
    if(command.name.begins_with("u_") or command.name.begins_with("d_") or command.name.begins_with("h_")):
      if((command.name.begins_with("u_") and not Console.devmode) or (command.name.begins_with("d_") and Console.devmode)):
        string += "[color=green]%s[/color], " % [str(command["name"]).substr(2)]
    else:
      string += str(command["name"]) + ", "
  return string.substr(0, string.length() - 2)

func u_devmode():
  Console.devmode = true
  return "Set Dev Mode"

func d_usermode():
  Console.devmode = false
  return "Removed Dev Mode"