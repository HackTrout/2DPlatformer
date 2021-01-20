tool
extends Sprite

#Variables
var motion : Vector2 = Vector2.ZERO #The Sprite's Veclocity
export(float) var stiffness = 1.0 #How strong the force is to getting to the target node. Higher values mean sticking more tightly to target
export(float, 0.0, 1.0, 0.01) var damping = 0.99 #Ensures the Sprite will eventually rest at the target position
export(NodePath) var target_node_path setget set_target_node_path #A path to that target node
var target_node : Node = null #The target the sprite will head towards


func _ready() -> void:
	#Get Target Node
	update_target_node()
	
	#Reposition
	if target_node != null:
		global_position = target_node.global_position


func set_target_node_path(val) -> void:
	target_node_path = val
	
	#Update
	update_target_node()


func update_target_node() -> void:
	#Get Target Node
	var node = get_node_or_null(target_node_path)
	if node != null:
		target_node = node


func _physics_process(delta):
	#Calculate Motion
	if target_node != null:
		motion += (target_node.global_position - global_position) * stiffness
	
	#Add Motion
	position += motion * delta
	
	#Damping
	motion *= damping
