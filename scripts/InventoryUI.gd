extends CanvasLayer

@export var player_path: NodePath

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var items_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Items
@onready var help_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Help

var player: Node = null
var is_open: bool = false
var selected_index: int = 0
var item_keys: Array[String] = []

func _ready() -> void:
	_ensure_input_action("inventory_toggle", KEY_TAB)
	panel.visible = false
	player = get_node_or_null(player_path)

	if player and player.has_signal("inventory_changed"):
		player.inventory_changed.connect(_on_inventory_changed)

	_refresh_display()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory_toggle"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return

	if not is_open:
		return

	if Input.is_action_just_pressed("ui_up"):
		selected_index = max(selected_index - 1, 0)
		_refresh_display()
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_down"):
		selected_index = min(selected_index + 1, max(item_keys.size() - 1, 0))
		_refresh_display()
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_accept"):
		_use_selected_item()
		get_viewport().set_input_as_handled()

func _toggle_inventory() -> void:
	is_open = not is_open
	panel.visible = is_open

	if player and player.has_method("set_controls_enabled"):
		player.set_controls_enabled(not is_open)

	if is_open:
		_refresh_display()

func _refresh_display() -> void:
	title_label.text = "Inventory"

	if not player or not player.has_method("get_inventory"):
		items_label.text = "Player belum terhubung."
		help_label.text = "Set player_path pada InventoryUI."
		item_keys.clear()
		selected_index = 0
		return

	var inventory: Dictionary = player.get_inventory()
	item_keys.clear()

	for key in inventory.keys():
		item_keys.append(str(key))

	item_keys.sort()

	if item_keys.is_empty():
		items_label.text = "(Kosong)"
		help_label.text = "Tab: Tutup"
		selected_index = 0
		return

	selected_index = clamp(selected_index, 0, item_keys.size() - 1)
	var lines: Array[String] = []

	for i in range(item_keys.size()):
		var key: String = item_keys[i]
		var marker := ">" if i == selected_index else " "
		lines.append("%s %s x%d" % [marker, key, int(inventory.get(key, 0))])

	items_label.text = "\n".join(lines)
	help_label.text = "Tab: Tutup | Up/Down: Pilih | Enter: Pakai"

func _use_selected_item() -> void:
	if not player or not player.has_method("use_inventory_item"):
		return
	if item_keys.is_empty():
		return

	var selected_item: String = item_keys[selected_index]
	var used: bool = player.use_inventory_item(selected_item, 1)
	if used:
		_refresh_display()

func _on_inventory_changed(_updated_inventory: Dictionary) -> void:
	if is_open:
		_refresh_display()

func _ensure_input_action(action_name: String, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == key_code:
			return

	var key_event := InputEventKey.new()
	key_event.keycode = key_code
	InputMap.action_add_event(action_name, key_event)
