class_name CameraController
extends Camera2D
## Camera RTS (S2.T05).
## PC: WASD/mũi tên hoặc kéo chuột phải/giữa để cuộn, lăn chuột để zoom.
## Cảm ứng: kéo hai ngón để cuộn, chụm hai ngón để zoom.
## Kéo một ngón chỉ cuộn khi bật one_finger_pan.

const ZOOM_MIN: float = 0.4
const ZOOM_MAX: float = 1.8
const ZOOM_STEP: float = 1.12
const KEY_SPEED: float = 900.0
const INERTIA_DECAY: float = 5.0
const INERTIA_STOP: float = 10.0

var bounds := Rect2()
var one_finger_pan: bool = false

var _touches: Dictionary = {}
var _pinch_start_distance: float = 0.0
var _pinch_start_zoom: float = 1.0
var _last_center := Vector2.ZERO
var _velocity := Vector2.ZERO
var _dragging: bool = false


func _init() -> void:
	# Camera tự di chuyển theo từng khung hình, không nội suy theo tick vật lý.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func set_bounds(map_pixel_size: Vector2) -> void:
	bounds = CameraMath.iso_bounds(map_pixel_size)
	_apply_clamp()


## Đưa camera tới điểm trong không gian sim (dùng cho minimap).
func jump_to_sim(sim_position: Vector2) -> void:
	position = Iso.to_screen(sim_position)
	_velocity = Vector2.ZERO
	_apply_clamp()


## Vùng nhìn thấy hiện tại, tính bằng px thế giới (iso).
func view_size() -> Vector2:
	return get_viewport_rect().size / zoom.x


func set_zoom_level(value: float) -> void:
	var clamped := clampf(value, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(clamped, clamped)


func zoom_at(cursor_offset: Vector2, factor: float) -> void:
	var old_zoom := zoom.x
	set_zoom_level(old_zoom * factor)
	position = CameraMath.zoom_about(position, old_zoom, zoom.x, cursor_offset)
	_apply_clamp()


func pan_by(screen_delta: Vector2) -> void:
	position -= screen_delta / zoom.x
	_apply_clamp()


func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction != Vector2.ZERO:
		position += direction.normalized() * KEY_SPEED * delta / zoom.x
		_velocity = Vector2.ZERO
		_apply_clamp()
	elif not _dragging and _velocity.length() > INERTIA_STOP:
		position -= _velocity * delta / zoom.x
		_velocity *= exp(-INERTIA_DECAY * delta)
		_apply_clamp()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion and _dragging:
		pan_by((event as InputEventMouseMotion).relative)
	elif event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	var cursor_offset := event.position - get_viewport_rect().size * 0.5
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			zoom_at(cursor_offset, ZOOM_STEP)
		MOUSE_BUTTON_WHEEL_DOWN:
			zoom_at(cursor_offset, 1.0 / ZOOM_STEP)
		MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
		if _touches.size() == 2:
			_pinch_start_distance = _touch_distance()
			_pinch_start_zoom = zoom.x
			_last_center = _touch_center()
	else:
		_touches.erase(event.index)
		_pinch_start_distance = 0.0


func _on_drag(event: InputEventScreenDrag) -> void:
	if not _touches.has(event.index):
		return
	_touches[event.index] = event.position
	if _touches.size() >= 2:
		_pinch_and_pan()
	elif one_finger_pan:
		pan_by(event.relative)
		_velocity = event.relative * 60.0


## Điểm thế giới dưới tâm hai ngón ở lần trước phải nằm dưới tâm hai ngón mới, với mức zoom mới.
func _pinch_and_pan() -> void:
	var half := get_viewport_rect().size * 0.5
	var new_center := _touch_center()
	var old_zoom := zoom.x
	if _pinch_start_distance > 0.0:
		set_zoom_level(_pinch_start_zoom * _touch_distance() / _pinch_start_distance)
	var anchor := position + (_last_center - half) / old_zoom
	position = anchor - (new_center - half) / zoom.x
	_velocity = (new_center - _last_center) * 60.0
	_last_center = new_center
	_apply_clamp()


func _touch_distance() -> float:
	var points: Array = _touches.values()
	return (points[0] as Vector2).distance_to(points[1] as Vector2)


func _touch_center() -> Vector2:
	var points: Array = _touches.values()
	return ((points[0] as Vector2) + (points[1] as Vector2)) * 0.5


func _apply_clamp() -> void:
	if bounds.size != Vector2.ZERO:
		position = CameraMath.clamp_center(position, view_size(), bounds)
