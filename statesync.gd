class_name Wait extends Node

##Completed is emited when there are no running wait, which happens when conditions are met.
signal completed

##The collection of wait should there be more than one.
var conditions := []

##The collection of callables should there be more than one, they are key'd to the wait id.
var processes := {}

##The wait unique id.
@export var id : int

##The name of the object this Wait is synching for.
@export var object_name : String = ""

func _init(_id : int) -> void:
	id = _id

##Checks if the process has reached completion
func is_completed() -> bool:
	return condition_completed(id)

## A Static construct for a single wait, it return wait and adds it to memory
static func for_condition(condition : Callable) -> Wait:
	var out : Wait = Wait.new(randi())
	out.conditions.append(out)
	out.processes[out.id] = condition
	out.object_name = "Object is not a node or callable was created statically."\
	 if !condition.get_object() is Node else condition.get_object().name
	return out

## A static construct for a group of waits, one for each callable, it returns the first wait and childs any extras to it.
static func for_group_condition(_conditions : Array[Callable]) -> Wait:
	var initial : Wait = null
	for i in range(_conditions.size()):
		var out : Wait = Wait.new(randi())
		if i == 0: 
			initial = out
		initial.conditions.append(out)
		out.processes[out.id] = _conditions[i]
		out.object_name = "Object is not a node or callable was created statically."\
		 if !_conditions[i].get_object() is Node else _conditions[i].get_object().name
		if i > 0: 
			out.process_mode = Node.PROCESS_MODE_DISABLED
			initial.add_child.bind(out).call_deferred()
	return initial

##Adds the await to the scene and begins the waiting process.
func activate(node : Node) -> void:
	if !node.is_inside_tree():
		printerr("Node must be in tree to be waited for.")
		return
	var parent := node.get_tree().root
	parent.add_child.bind(self).call_deferred()
	await completed

##Checks for this wait process to be completed, as well as its children.
func condition_completed(_id : int) -> bool:
	var result = processes[_id].call()
	if result is bool:
		return result
	elif result is Object:
		return true
	elif result is String:
		return result != ""
	elif result is Array or result is Dictionary:
		return !result.is_empty()
	else:
		return false

##Handles the top most wait process, all other processes are disabled if part of a group.
func _process(_delta : float) -> void:
	conditions = conditions.filter(
		func(condition : Wait) -> bool:
			if condition.is_completed():
				processes.erase(condition.id)
				condition.queue_free()
				return false
			return true
	)
	
	if conditions.size() > 0: return
	completed.emit()
