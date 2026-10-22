class_name GestureRecognizer
extends RefCounted
## Nhận diện cử chỉ trên bản đồ (S3.T01): chạm, chạm đúp, giữ rồi kéo = khung chọn,
## kéo/chụm hai ngón. Không đọc Input trực tiếp: lớp ngoài truyền vào chạm xuống/di chuyển/nhả
## kèm thời điểm (ms), nên test được mà không cần màn hình cảm ứng. Toạ độ và ngưỡng tính theo pt.

signal tap(position: Vector2)
signal double_tap(position: Vector2)
signal box_armed(position: Vector2)  ## giữ đủ lâu; lớp ngoài rung nhẹ 10 ms
signal box_start(position: Vector2)
signal box_update(from: Vector2, to: Vector2)
signal box_end(from: Vector2, to: Vector2)
signal pan(delta: Vector2)
signal pinch(center: Vector2, ratio: float)

enum State { IDLE, PRESSED, BOX_ARMED, BOX, PAN, TWO_FINGER, NONE }

const TAP_SLOP: float = 8.0
const TAP_MAX_MS: int = 250
const DOUBLE_TAP_MS: int = 300
const DOUBLE_TAP_DISTANCE: float = 30.0
const HOLD_BOX_MS: int = 300

## Bật nút "Chọn vùng": kéo ngay là có khung chọn, không cần giữ.
var select_area_mode: bool = false
## Bật tuỳ chọn kéo một ngón để cuộn bản đồ.
var one_finger_pan: bool = false

var state: State = State.IDLE

var _points: Dictionary = {}  # index -> Vector2, chỉ các ngón nằm trên bản đồ
var _hud_pointers: Dictionary = {}  # index -> true, các ngón bắt đầu trên HUD
var _start: Vector2 = Vector2.ZERO
var _start_ms: int = 0
var _last_position: Vector2 = Vector2.ZERO
var _has_last_tap: bool = false
var _last_tap_ms: int = 0
var _last_tap_position: Vector2 = Vector2.ZERO
var _last_center: Vector2 = Vector2.ZERO
var _last_distance: float = 0.0


func reset() -> void:
	_points.clear()
	_hud_pointers.clear()
	_has_last_tap = false
	state = State.IDLE


## Gọi mỗi khung hình để bắt được thời điểm giữ đủ lâu khi ngón không nhúc nhích.
func update(now_ms: int) -> void:
	_arm_if_held(now_ms)


func touch_down(index: int, position: Vector2, now_ms: int, on_hud: bool = false) -> void:
	if on_hud:
		_hud_pointers[index] = true
		return
	_points[index] = position
	if _points.size() == 1:
		state = State.PRESSED
		_start = position
		_start_ms = now_ms
		_last_position = position
	elif _points.size() == 2 and state != State.BOX and state != State.TWO_FINGER:
		state = State.TWO_FINGER
		_last_center = _center()
		_last_distance = _distance()


func touch_move(index: int, position: Vector2, now_ms: int) -> void:
	if not _points.has(index):
		return
	_arm_if_held(now_ms)
	_points[index] = position
	match state:
		State.PRESSED:
			_move_pressed(position)
		State.BOX_ARMED:
			if position.distance_to(_start) > TAP_SLOP:
				_begin_box(position)
		State.BOX:
			box_update.emit(_start, position)
		State.PAN:
			pan.emit(position - _last_position)
		State.TWO_FINGER:
			_move_two_fingers()
	_last_position = position


func touch_up(index: int, position: Vector2, now_ms: int) -> void:
	if _hud_pointers.has(index):
		_hud_pointers.erase(index)
		return
	if not _points.has(index):
		return
	_arm_if_held(now_ms)
	_points.erase(index)
	match state:
		State.PRESSED:
			if now_ms - _start_ms <= TAP_MAX_MS:
				_emit_tap(position, now_ms)
		State.BOX:
			box_end.emit(_start, position)
		State.TWO_FINGER:
			if not _points.is_empty():
				state = State.NONE  # ngón còn lại không còn làm gì cho tới khi nhấc hết
	if _points.is_empty():
		state = State.IDLE


func _arm_if_held(now_ms: int) -> void:
	if (
		state == State.PRESSED
		and now_ms - _start_ms >= HOLD_BOX_MS
		and _last_position.distance_to(_start) <= TAP_SLOP
	):
		state = State.BOX_ARMED
		box_armed.emit(_start)


func _move_pressed(position: Vector2) -> void:
	if position.distance_to(_start) <= TAP_SLOP:
		return
	if select_area_mode:
		_begin_box(position)
	elif one_finger_pan:
		state = State.PAN
		pan.emit(position - _start)
	else:
		state = State.NONE  # kéo sớm mà không có chế độ nào: bỏ cử chỉ, nhả tay cũng không thành chạm


func _begin_box(position: Vector2) -> void:
	state = State.BOX
	box_start.emit(_start)
	box_update.emit(_start, position)


func _move_two_fingers() -> void:
	var center := _center()
	var distance := _distance()
	if center != _last_center:
		pan.emit(center - _last_center)
	if distance != _last_distance and _last_distance > 0.0:
		pinch.emit(center, distance / _last_distance)
	_last_center = center
	_last_distance = distance


func _emit_tap(position: Vector2, now_ms: int) -> void:
	tap.emit(position)
	if (
		_has_last_tap
		and now_ms - _last_tap_ms <= DOUBLE_TAP_MS
		and position.distance_to(_last_tap_position) <= DOUBLE_TAP_DISTANCE
	):
		_has_last_tap = false
		double_tap.emit(position)
		return
	_has_last_tap = true
	_last_tap_ms = now_ms
	_last_tap_position = position


func _center() -> Vector2:
	var sum := Vector2.ZERO
	for point: Vector2 in _points.values():
		sum += point
	return sum / maxf(1.0, _points.size())


func _distance() -> float:
	var values := _points.values()
	if values.size() < 2:
		return 0.0
	return (values[0] as Vector2).distance_to(values[1] as Vector2)
