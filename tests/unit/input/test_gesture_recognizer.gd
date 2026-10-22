extends GdUnitTestSuite
## S3.T01: nhận diện cử chỉ.

var _log: Array[String] = []
var _gesture: GestureRecognizer


func before_test() -> void:
	_log = []
	_gesture = GestureRecognizer.new()
	_gesture.tap.connect(func(_p: Vector2) -> void: _log.append("tap"))
	_gesture.double_tap.connect(func(_p: Vector2) -> void: _log.append("double_tap"))
	_gesture.box_armed.connect(func(_p: Vector2) -> void: _log.append("box_armed"))
	_gesture.box_start.connect(func(_p: Vector2) -> void: _log.append("box_start"))
	_gesture.box_update.connect(func(_a: Vector2, _b: Vector2) -> void: _log.append("box_update"))
	_gesture.box_end.connect(func(_a: Vector2, _b: Vector2) -> void: _log.append("box_end"))
	_gesture.pan.connect(func(_d: Vector2) -> void: _log.append("pan"))
	_gesture.pinch.connect(func(_c: Vector2, _r: float) -> void: _log.append("pinch"))


func _tap_at(at_ms: int, duration_ms: int = 80, where: Vector2 = Vector2(100, 100)) -> void:
	_gesture.touch_down(0, where, at_ms)
	_gesture.touch_up(0, where + Vector2(3, 0), at_ms + duration_ms)


func test_s3_t01_tc1_a_short_press_with_small_movement_is_a_tap() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_move(0, Vector2(103, 100), 40)
	_gesture.touch_up(0, Vector2(103, 100), 80)
	assert_array(_log).is_equal(["tap"])


func test_s3_t01_tc2_two_taps_250_ms_apart_make_a_double_tap() -> void:
	_tap_at(0)
	_tap_at(250)
	assert_array(_log).is_equal(["tap", "tap", "double_tap"])


func test_taps_too_far_apart_in_time_or_space_are_not_a_double_tap() -> void:
	_tap_at(0)
	_tap_at(600)
	_tap_at(1000, 80, Vector2(300, 100))
	assert_array(_log).is_equal(["tap", "tap", "tap"])


func test_a_third_quick_tap_does_not_make_another_double_tap() -> void:
	_tap_at(0)
	_tap_at(200)
	_tap_at(400)
	assert_array(_log).is_equal(["tap", "tap", "double_tap", "tap"])


func test_s3_t01_tc3_hold_300_ms_then_drag_starts_a_selection_box() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_move(0, Vector2(140, 100), 320)
	assert_array(_log).is_equal(["box_armed", "box_start", "box_update"])
	_gesture.touch_move(0, Vector2(160, 110), 340)
	_gesture.touch_up(0, Vector2(160, 110), 360)
	assert_array(_log).is_equal(["box_armed", "box_start", "box_update", "box_update", "box_end"])


func test_holding_without_moving_arms_the_box_through_update() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.update(299)
	assert_array(_log).is_empty()
	_gesture.update(300)
	assert_array(_log).is_equal(["box_armed"])


func test_releasing_an_armed_box_without_moving_cancels_it() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.update(350)
	_gesture.touch_up(0, Vector2(100, 100), 400)
	assert_array(_log).is_equal(["box_armed"])


func test_s3_t01_tc4_hold_200_ms_then_drag_does_nothing() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_move(0, Vector2(140, 100), 200)
	_gesture.touch_up(0, Vector2(140, 100), 260)
	assert_array(_log).is_empty()


func test_a_press_between_250_and_300_ms_is_neither_tap_nor_box() -> void:
	_tap_at(0, 280)
	assert_array(_log).is_empty()


func test_s3_t01_tc5_select_area_mode_drags_a_box_straight_away() -> void:
	_gesture.select_area_mode = true
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_move(0, Vector2(130, 100), 60)
	_gesture.touch_up(0, Vector2(130, 100), 100)
	assert_array(_log).is_equal(["box_start", "box_update", "box_end"])


func test_s3_t01_tc6_two_fingers_pinch_and_do_not_make_a_tap() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_down(1, Vector2(200, 100), 10)
	_gesture.touch_move(1, Vector2(260, 100), 50)
	_gesture.touch_up(1, Vector2(260, 100), 90)
	_gesture.touch_up(0, Vector2(100, 100), 100)
	assert_bool(_log.has("pinch")).is_true()
	assert_bool(_log.has("tap")).is_false()
	assert_int(_gesture.state).is_equal(GestureRecognizer.State.IDLE)


func test_two_fingers_that_only_touch_and_lift_make_no_tap() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_down(1, Vector2(200, 100), 10)
	_gesture.touch_up(1, Vector2(200, 100), 60)
	_gesture.touch_up(0, Vector2(100, 100), 70)
	assert_array(_log).is_empty()


func test_pinch_ratio_follows_the_distance_between_fingers() -> void:
	var ratios: Array[float] = []
	_gesture.pinch.connect(func(_c: Vector2, ratio: float) -> void: ratios.append(ratio))
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_down(1, Vector2(200, 100), 0)
	_gesture.touch_move(1, Vector2(300, 100), 20)
	assert_float(ratios[0]).is_equal_approx(2.0, 0.001)


func test_moving_both_fingers_together_pans() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_down(1, Vector2(200, 100), 0)
	_gesture.touch_move(0, Vector2(110, 100), 10)
	_gesture.touch_move(1, Vector2(210, 100), 10)
	assert_bool(_log.has("pan")).is_true()


func test_s3_t01_tc7_a_touch_that_starts_on_the_hud_gives_no_map_gesture() -> void:
	_gesture.touch_down(0, Vector2(20, 100), 0, true)
	_gesture.touch_move(0, Vector2(80, 100), 400)
	_gesture.touch_up(0, Vector2(80, 100), 500)
	assert_array(_log).is_empty()
	assert_int(_gesture.state).is_equal(GestureRecognizer.State.IDLE)


func test_a_hud_finger_does_not_turn_a_map_touch_into_two_fingers() -> void:
	_gesture.touch_down(7, Vector2(20, 100), 0, true)
	_tap_at(10)
	assert_array(_log).is_equal(["tap"])


func test_one_finger_pan_scrolls_when_enabled() -> void:
	_gesture.one_finger_pan = true
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.touch_move(0, Vector2(130, 100), 30)
	_gesture.touch_move(0, Vector2(150, 100), 50)
	_gesture.touch_up(0, Vector2(150, 100), 60)
	assert_array(_log).is_equal(["pan", "pan"])


func test_reset_forgets_everything_in_progress() -> void:
	_gesture.touch_down(0, Vector2(100, 100), 0)
	_gesture.reset()
	assert_int(_gesture.state).is_equal(GestureRecognizer.State.IDLE)
	_gesture.touch_up(0, Vector2(100, 100), 50)
	assert_array(_log).is_empty()
