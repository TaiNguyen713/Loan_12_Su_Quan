extends GdUnitTestSuite
## S2.T05: camera RTS.

const MAP_PIXELS := Vector2(128 * 32, 96 * 32)


func _camera() -> CameraController:
	var camera := CameraController.new()
	add_child(auto_free(camera))
	camera.set_bounds(MAP_PIXELS)
	camera.jump_to_sim(MAP_PIXELS * 0.5)
	return camera


func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event


func _drag(index: int, position: Vector2, relative: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	event.relative = relative
	return event


func test_s2_t05_tc1_two_finger_pan_moves_by_the_drag_divided_by_zoom() -> void:
	var camera := _camera()
	camera.set_zoom_level(1.6)
	var start_point := camera.position
	camera.pan_by(Vector2(100, 0))
	assert_vector(camera.position).is_equal_approx(
		start_point - Vector2(62.5, 0), Vector2(0.01, 0.01)
	)


func test_s2_t05_tc2_one_finger_drag_does_not_scroll_by_default() -> void:
	var camera := _camera()
	var start_point := camera.position
	camera._unhandled_input(_touch(0, Vector2(300, 300), true))
	camera._unhandled_input(_drag(0, Vector2(400, 300), Vector2(100, 0)))
	assert_vector(camera.position).is_equal(start_point)


func test_one_finger_drag_scrolls_when_the_setting_is_on() -> void:
	var camera := _camera()
	camera.one_finger_pan = true
	var start_point := camera.position
	camera._unhandled_input(_touch(0, Vector2(300, 300), true))
	camera._unhandled_input(_drag(0, Vector2(400, 300), Vector2(100, 0)))
	assert_bool(camera.position.x < start_point.x).is_true()


func test_s2_t05_tc3_pinch_zooms_and_keeps_the_center_still() -> void:
	var camera := _camera()
	camera.set_zoom_level(0.6)
	var middle := camera.get_viewport_rect().size * 0.5
	var finger_a := middle + Vector2(-50, 0)
	var finger_b := middle + Vector2(50, 0)
	var world_under_center := camera.position
	camera._unhandled_input(_touch(0, finger_a, true))
	camera._unhandled_input(_touch(1, finger_b, true))
	camera._unhandled_input(_drag(0, finger_a + Vector2(-50, 0), Vector2(-50, 0)))
	camera._unhandled_input(_drag(1, finger_b + Vector2(50, 0), Vector2(50, 0)))
	assert_float(camera.zoom.x).is_equal_approx(1.2, 0.001)
	assert_vector(camera.position).is_equal_approx(world_under_center, Vector2(2, 2))


func test_zoom_is_clamped_between_the_limits() -> void:
	var camera := _camera()
	camera.set_zoom_level(100.0)
	assert_float(camera.zoom.x).is_equal_approx(CameraController.ZOOM_MAX, 0.0001)
	camera.set_zoom_level(0.0001)
	assert_float(camera.zoom.x).is_equal_approx(CameraController.ZOOM_MIN, 0.0001)


func test_s2_t05_tc5_camera_stays_inside_the_map_bounds() -> void:
	var camera := _camera()
	camera.set_zoom_level(1.0)
	camera.pan_by(Vector2(-1.0e7, -1.0e7))
	var half := camera.view_size() * 0.5
	assert_bool(camera.position.x - half.x >= camera.bounds.position.x - 0.01).is_true()
	assert_bool(camera.position.y - half.y >= camera.bounds.position.y - 0.01).is_true()
	camera.pan_by(Vector2(1.0e7, 1.0e7))
	assert_bool(camera.position.x + half.x <= camera.bounds.end.x + 0.01).is_true()
	assert_bool(camera.position.y + half.y <= camera.bounds.end.y + 0.01).is_true()


func test_jump_to_sim_centers_on_that_point() -> void:
	var camera := _camera()
	var target := Vector2(40 * 32, 30 * 32)
	camera.jump_to_sim(target)
	assert_vector(camera.position).is_equal_approx(Iso.to_screen(target), Vector2(0.01, 0.01))


func test_s2_t05_tc6_wheel_zoom_keeps_the_point_under_the_cursor() -> void:
	var camera := _camera()
	var cursor := Vector2(200, -100)
	var start_point := camera.position + cursor / camera.zoom.x
	camera.zoom_at(cursor, 1.12)
	var end_point := camera.position + cursor / camera.zoom.x
	assert_vector(end_point).is_equal_approx(start_point, Vector2(0.01, 0.01))
