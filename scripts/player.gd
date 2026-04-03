extends CharacterBody3D

signal inventory_changed(updated_inventory: Dictionary)

@export var normal_speed: float = 10.0
@export var sprint_speed: float = 16.0
@export var crouch_speed: float = 5.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3
@export var crouch_head_offset: float = 0.6
@export var crouch_transition_speed: float = 8.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var camera_x_rotation: float = 0.0
var inventory: Dictionary = {}
var _standing_head_height: float = 0.0
var _target_head_height: float = 0.0
var _is_crouching: bool = false
var _controls_enabled: bool = true

func _ready():
	_ensure_input_action("sprint", KEY_SHIFT)
	_ensure_input_action("crouch", KEY_CTRL)

	_standing_head_height = head.position.y
	_target_head_height = _standing_head_height

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if not _controls_enabled:
		return

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	if not _controls_enabled:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	var movement_vector = Vector3.ZERO
	_is_crouching = Input.is_action_pressed("crouch")

	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()
	var active_speed = _get_active_speed()
	_target_head_height = _standing_head_height - crouch_head_offset if _is_crouching else _standing_head_height
	head.position.y = lerp(head.position.y, _target_head_height, crouch_transition_speed * delta)

	velocity.x = lerp(velocity.x, movement_vector.x * active_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * active_speed, acceleration * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_crouching:
		velocity.y = jump_power

	move_and_slide()

func add_to_inventory(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false

	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	inventory_changed.emit(get_inventory())
	print("Picked up %s x%d. Total: %d" % [item_id, amount, inventory[item_id]])
	return true

func get_inventory() -> Dictionary:
	return inventory.duplicate(true)

func use_inventory_item(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false
	if not inventory.has(item_id):
		return false

	var current_amount: int = int(inventory[item_id])
	if current_amount < amount:
		return false

	inventory[item_id] = current_amount - amount
	if int(inventory[item_id]) <= 0:
		inventory.erase(item_id)

	_apply_item_effect(item_id, amount)
	inventory_changed.emit(get_inventory())
	return true

func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _get_active_speed() -> float:
	if _is_crouching:
		return crouch_speed
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return normal_speed

func _ensure_input_action(action_name: String, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == key_code:
			return

	var key_event := InputEventKey.new()
	key_event.keycode = key_code
	InputMap.action_add_event(action_name, key_event)

func _apply_item_effect(item_id: String, amount: int) -> void:
	if item_id == "energy_cell":
		jump_power = min(jump_power + (0.5 * amount), 8.0)
		print("Used %s x%d. Jump power is now %.2f" % [item_id, amount, jump_power])
		return

	print("Used %s x%d" % [item_id, amount])
