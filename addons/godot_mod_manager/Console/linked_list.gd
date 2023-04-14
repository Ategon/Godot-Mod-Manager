class_name LinkedList
extends RefCounted
## A doubly linked list implementation
##
## An implementation of a doubly linked list. Excels with adding and removing 
## data from the front and back of the list while taking longer to interact with
## things in the middle.

var _first: Link = null
var _last: Link = _first
var _amount: int = 0


func size() -> int:
	return _amount


func getFirst() -> Link:
	return _first


func getLast() -> Link:
	return _last


func getLink(index: int) -> Link:
	if(index >= _amount):
		return null
	
	if(index == _amount - 1):
		return getLast()
	
	if(index == 0):
		return getFirst()
	
	var i = 0
	var reference = _first
	
	while(i < index):
		if(reference == null):
			return null
		reference = reference.next
		i += 1
	
	return reference


func addFirst(newData: Variant) -> Link:
	var newLink = Link.new(newData)
	
	if(_first):
		newLink.next = _first
		_first.prev = newLink
	
	_first = newLink
	
	if(not _last):
		_last = _first
	
	_amount += 1
	return _first

	
func addLast(newData: Variant) -> Link:
	var newLink = Link.new(newData)
	
	if(_last):
		newLink.prev = _last
		_last.next = newLink
	
	_last = newLink
	
	if(not _first):
		_first = _last
	
	_amount += 1
	return _last


func addLink(newData: Variant, index: int) -> Link:
	if(index > _amount):
		return null
	
	if(index == _amount):
		return addLast(newData)
	
	if(index == 0):
		return addFirst(newData)
		
	var newLink = Link.new(newData)
	
	var nextLink = getLink(index)
	var previousLink = nextLink.prev
	
	previousLink.next = newLink
	nextLink.prev = newLink
	
	newLink.prev = previousLink
	newLink.next = nextLink
	
	_amount += 1
	return newLink

	
func removeFirst() -> Link:
	if(not _first):
		return null
	
	var oldData = _first
	if(_first.next):
		_first.next.prev = null
	_first = _first.next
	
	if(_amount == 2):
		_last = _first
	
	_amount -= 1
	return oldData
	
func removeLast() -> Link:
	if(not _last):
		return null
	
	var oldData = _last
	if(_last.prev):
		_last.prev.next = null
	_last = _last.prev
	
	if(_amount == 2):
		_first = _last
	
	_amount -= 1
	return oldData

func removeLink(index: int) -> Link:
	if(index >= _amount):
		return null
	
	if(index == _amount - 1):
		return removeLast()
	
	if(index == 0):
		return removeFirst()
	
	var removedLink = getLink(index)
	var nextLink = removedLink.next
	var previousLink = removedLink.prev
	
	nextLink.prev = previousLink
	previousLink.next = nextLink
		
	_amount -= 1
	return Link.new(null)

func _to_string() -> String:
	return "Linked List: %d elements" % [_amount]
