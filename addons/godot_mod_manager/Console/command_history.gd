extends Node

var history = LinkedList.new()
var max_history = 100

var commandhistoryline = history.size()

func addHistory(newLine):
	if history.size() > max_history:
		history.removeFirst()
	
	history.addLast(newLine)
