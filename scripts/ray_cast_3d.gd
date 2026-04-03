extends RayCast3D

var current_collider

func _ready():
	pass

func _process(delta):
	var collider = get_collider()
	var interactor := _find_interactor()

	if is_colliding() and collider is Interactable:
		if Input.is_action_just_pressed("interact"):
			collider.interact(interactor)

func _find_interactor() -> Node:
	var candidate: Node = get_parent()

	while candidate:
		if candidate is CharacterBody3D:
			return candidate
		candidate = candidate.get_parent()

	return null
