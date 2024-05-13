How to use StateSync:

Requirements:
	1. There needs to be an active scene tree, statesync's activate() will not work if there is no active tree.
	2. Activate requires a node that is presently in the scene tree to be passed in, this could be any node so long
	   as it is within the scene tree when activate is called.

The Problem:
	As projects get larger losing track of when an object may exist or a value may be something you need becomes troublesome. 
	To my knowledge the Godot solution is to use create_timer() and I wanted something else.
	The result of using this system for me is a weight off my shoulders as I do not need to care about the timing of when some
	value or collection is what I need it to be any longer.

Debugging:
	There are programmatic approaches to debugging as well as visual, all Waits appear on the heirarchy and nodes within groups
	are childed to the first node of that group. 
	With group nodes only the first node of that group is running any processes and the children are batched to it.
	The nodes display a unique id as well as the name of the object which is awaiting. If the object has no name there is a
	default text informing you as much.

Using this:
	The usage of this is very simple let's break it into 3 parts.
	
	1. 'await' this is a built in function in Godot, it turns any function it is called within into a coroutine
	so it isn't good to do this inside a _init(). This is again by default in Godot.
	
	2. `Wait.for_condtition() && Wait.for_group_condition()` these two functions construct the Wait and adds them to memory.
	They both return a single Wait which can be cached if need be, that also means that you can create this via `@onready`
	for later use in your script. Similarly storing the Wait result allows for access to the script for debugging if wanted.
	`for_condition(...)` expects a single lamda expression aka callable the lamda should always return a type.
	
	Examples of lamda's are: `func(): return foo == true`.
	
	The condition constructors can work with return types of bools, objects, collections and strings. `for_group_condition`
	works the same as `for_condition` but takes an Array of the types of lamda. Here are 2 examples of uses:
	
	`var foo_object : Node = foo_node.instantiate()
	await Wait.for_condition(func(): return foo_object).activate(self)
	"or"
	await Wait.for_condition(func(): return foo_object != null).activate(self)`
		
	The above are the same expression to this tool. Also we are assuming 'self' is a node that is on the current scene tree.
	If you are using Wait outside of the scene tree you can pass any autoload on the scene tree into activate as well.
	
	Below is the group example:
		
	`var is_dirty : bool = false
	var foo_object : Node = foo_node.instantiate()
	await Wait.for_group_condition([func(): return foo_object, func(): return is_dirty == true]).activate(self)
	
	The group will not proceed until all the elements of the group have entered the desired state.

	3. `Activate & Storage` you can store or activate Wait constructions. However activate is a coroutine and will only
	function as intended with an await before it. Recall the _init() restriction on await I mentioned above, this is a 
	built in Godot situation, _init() constructors cannot also be coroutines. So instead you can create your Wait in
	your _init() then pass it out and await it elsewhere.
	
	`func _init(foo):
		var storage = Wait.for_condition(func(): return foo)
		_handle_foo(storage, foo)
	
	func _handle_foo(storage, foo):
		await storage.activate(self)
		...`
	
	The above is again assuming self is a node on the scene tree. But this shows how you can manipulate this data.

Take Away:
	Thank you for using this, and you can contact me on Discord 'Arte' should you have any questions:
		Mikra Arts Server: https://discord.com/invite/k5Fc8bmvV4
