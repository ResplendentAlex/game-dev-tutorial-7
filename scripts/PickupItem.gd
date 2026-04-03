extends Interactable

@export var item_id: String = "coin"
@export var amount: int = 1

func interact(interactor: Node = null):
	if interactor == null:
		return
	if not interactor.has_method("add_to_inventory"):
		return

	var pickup_success: bool = interactor.add_to_inventory(item_id, amount)
	if pickup_success:
		var root = get_parent()
		if root:
			root.queue_free()
		else:
			queue_free()
