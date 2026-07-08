extends Node3D
class_name ConceptCameraController

@export var camera: Camera3D
@export var yaw_degrees := 0.0
@export var pitch_degrees := -58.0
@export var distance := 8.4
@export var min_distance := 5.4
@export var max_distance := 11.6
@export var rotate_speed := 0.18
@export var zoom_step := 0.45


func _ready() -> void:
	_update_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw_degrees -= event.relative.x * rotate_speed
		pitch_degrees = clampf(pitch_degrees - event.relative.y * rotate_speed, -78.0, -34.0)
		_update_camera()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(min_distance, distance - zoom_step)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(max_distance, distance + zoom_step)
			_update_camera()


func _update_camera() -> void:
	if not is_instance_valid(camera):
		return

	rotation_degrees = Vector3(0.0, yaw_degrees, 0.0)
	camera.position = Vector3(0.0, sin(deg_to_rad(-pitch_degrees)) * distance, cos(deg_to_rad(-pitch_degrees)) * distance)
	camera.rotation_degrees = Vector3(pitch_degrees, 0.0, 0.0)
