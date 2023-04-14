class_name Link
extends RefCounted
## An individual link used for linked lists
##
## An individual link containing data used for linked lists. Contains references
## to the next and previous links as well as the data used for this link.

var next: Link = null
var prev: Link = null
var data: Variant = null

func _init(value: Variant) -> void:
	self.data = value
	return

func _to_string() -> String:
	return "%s" % [data]
